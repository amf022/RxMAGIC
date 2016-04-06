class PrescriptionController < ApplicationController

  def index
    # This function serves the main table for prescriptions

    @prescriptions = Prescription.where("voided = ? ", false).order(created_at: :asc)
  end

  def show
    @prescription = Prescription.where(:rx_id => params[:id]).first rescue nil

    if @prescription.blank?
      redirect_to "/prescription"
    end

    meds = PmapInventory.where("patient_id = ? and rxaui = ? and current_quantity > ? and voided = ?",
                                   @prescription.patient_id, @prescription.rxaui, 0,
                                   false).order(expiration_date: :asc).pluck(:pap_identifier,:lot_number,
                                                                             :expiration_date,:current_quantity)

    @suggestions =[]
    if meds.blank?
      meds = GeneralInventory.where("rxaui = ? and current_quantity > ? and voided = ?", @prescription.rxaui,0,
                                       false).order(expiration_date: :asc).limit(5).pluck(:gn_identifier, :lot_number,
                                                                                         :expiration_date,:current_quantity)
    end

    (meds || []).each do |item|
      @suggestions << {"id" => Misc.dash_formatter(item[0]),"lot_number" => Misc.dash_formatter(item[1]),
                       "expiry_date" => (item[2].to_date.strftime('%b %d, %Y') rescue ""),"amount_remaining" => item[3]}
    end

  end

  def edit
  end

  def destroy
    # This function voids a prescription and marks it as deleted

    prescription = Prescription.find(params[:id])
    prescription.update_attributes(:voided => true)
    redirect_to "/prescription"
  end

  def dispense

    # First we check which inventory we are dispensing from
    bottle = params[:bottl_id].match(/gn/i)? "General" : "PMAP"

    #Dispense according to inventory while paying attention to possible race conditions
    case bottle
      when "PMAP"
        PmapInventory.transaction do
          item = PmapInventory.where("pap_identifier = ? ", params[:bottle_id]).lock(true).first
          item.current_quantity -= params[:quantity]
          item.save
        end


      when "General"
        GeneralInventory.transaction do
          item = GeneralInventory.where("gn_identifier = ? ", params[:bottle_id]).lock(true).first
          item.current_quantity -= params[:quantity]
          item.save
        end

    end

  end

  def ajax_prescriptions
    # this function services the application dashboard

    prescriptions =  Prescription.where("voided = ? AND date_prescribed BETWEEN ? AND ?",FALSE, Time.now.advance(:minutes => -30).strftime('%Y-%m-%d %H:%M:%S'),Time.now.strftime('%Y-%m-%d %H:%M:%S'))
    render :text => view_context.prescriptions(prescriptions).to_json
  end
end
