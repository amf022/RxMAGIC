class PrescriptionController < ApplicationController

  def index
    # This function serves the main table for prescriptions

    @prescriptions = Prescription.where("voided = ? AND quantity > amount_dispensed", false).order(created_at: :asc)
  end

  def show
    @prescription = Prescription.where(:rx_id => params[:id]).first rescue nil

    if @prescription.blank?
      redirect_to "/prescription"
    end

    @category, @suggestions = get_suggestions(@prescription.patient_id, @prescription.rxaui)

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
    bottle = params[:dispensation][:dispense_from].match(/g/i)? "General" : "PMAP"

    bottle_id = params[:dispensation][:dispense_from].gsub("$", "")

    if bottle == "PMAP"
      temp = PmapInventory.where("pap_identifier = ? ", bottle_id).pluck(:voided).first
      bottle = (temp == false ? "PMAP" : "General")
    end

    @prescription = Prescription.find(params[:dispensation][:prescription])

    item = nil
    #Dispense according to inventory while paying attention to possible race conditions
    case bottle
      when "PMAP"
        PmapInventory.transaction do
          item = PmapInventory.where("pap_identifier = ? AND voided = ?", bottle_id, false).first
          if !item.blank?
              if dispense_item(item,@prescription,params[:dispensation][:amount_dispensed])
                flash[:success] = "#{params[:dispensation][:amount_dispensed]} of #{item.drug_name} successfuly dispensed"
              else
                flash[:errors] = {} if flash[:errors].blank?
                flash[:errors][:insufficient_quantity] = ["#{item.drug_name} could not be dispensed"]
              end
          else
            flash[:errors] = {} if flash[:errors].blank?
            flash[:errors][:missing] = ["Item with bottle ID #{params[:id]} could not be found"]
          end
        end

      when "General"
        GeneralInventory.transaction do
          item = GeneralInventory.where("gn_identifier = ? AND voided = ?", bottle_id, false).first
          if !item.blank?
            if dispense_item(item,@prescription,params[:dispensation][:amount_dispensed])
              flash[:success] = "#{params[:dispensation][:amount_dispensed]} of #{item.drug_name} successfuly dispensed"
            else
              flash[:errors] = {} if flash[:errors].blank?
              flash[:errors][:insufficient_quantity] = ["#{item.drug_name} could not be dispensed"]
            end
          else
            flash[:errors] = {} if flash[:errors].blank?
            flash[:errors][:missing] = ["Item with bottle ID #{params[:id]} could not be found"]
          end
        end
    end


    if @prescription.quantity <= @prescription.amount_dispensed
      News.resolve(params[:dispensation][:prescription],"new prescription","prescritption filled")
      print_and_redirect("/print_dispensation_label/#{@prescription.id}", "/prescription")
    else
      redirect_to @prescription
    end

  end

  def refill
    @patient = Patient.find(params[:prescription][:patient_id])
    bottle = params[:prescription][:bottle_id].match(/g/i)? "General" : "PMAP"

    if bottle == "PMAP"
      temp = PmapInventory.where("pap_identifier = ? ", params[:prescription][:bottle_id]).pluck(:voided).first
      bottle = (temp == false ? "PMAP" : "General")
    end

    provider = Provider.where("first_name = ? AND last_name = ?",
                              params[:prescription][:prescribed_by].split(" ")[0],
                              params[:prescription][:prescribed_by].split(" ")[1]).first
    if provider.blank?
      provider = Provider.new
      provider.first_name = params[:prescription][:prescribed_by].split(" ")[0]
      provider.last_name = params[:prescription][:prescribed_by].split(" ")[1] rescue params[:prescription][:prescribed_by].split(" ")[0]
      provider.save
    end


    case bottle
      when "PMAP"
        PmapInventory.transaction do
          item = PmapInventory.where("pap_identifier = ? AND voided = ?", params[:prescription][:bottle_id], false).lock(true).first
          item.current_quantity = item.current_quantity.to_i - params[:prescription][:quantity_dispensed].to_i
          item.save

          @new_prescription = Prescription.new
          @new_prescription.patient_id = @patient.id
          @new_prescription.rxaui = item.rxaui
          @new_prescription.directions = params[:prescription][:directions] + " [Refill]"
          @new_prescription.quantity = params[:prescription][:quantity_dispensed]
          @new_prescription.amount_dispensed = params[:prescription][:quantity_dispensed]
          @new_prescription.provider_id = provider.id
          @new_prescription.date_prescribed = Time.now
          @new_prescription.save

          @dispensation = Dispensation.create({:rx_id => @new_prescription.id, :inventory_id => item.bottle_id,
                                              :patient_id => @new_prescription.patient_id, :quantity => @new_prescription.amount_dispensed,
                                              :dispensation_date => Time.now})
        end


      when "General"
        GeneralInventory.transaction do
          item = GeneralInventory.where("gn_identifier = ? ", params[:prescription][:bottle_id]).lock(true).first
          item.current_quantity = item.current_quantity.to_i - params[:prescription][:quantity_dispensed].to_i
          item.save

          @new_prescription = Prescription.new
          @new_prescription.patient_id = @patient.id
          @new_prescription.rxaui = item.rxaui
          @new_prescription.directions = params[:prescription][:directions] + " [Refill]"
          @new_prescription.quantity = params[:prescription][:quantity_dispensed]
          @new_prescription.amount_dispensed = params[:prescription][:quantity_dispensed]
          @new_prescription.provider_id = provider.id
          @new_prescription.date_prescribed = Time.now
          @new_prescription.save

          @dispensation = Dispensation.create({:rx_id => @new_prescription.id, :inventory_id => item.bottle_id,
                                              :patient_id => @new_prescription.patient_id, :quantity => @new_prescription.amount_dispensed,
                                              :dispensation_date => Time.now})

        end
    end

    if @dispensation.errors.blank?
      print_and_redirect("/print_dispensation_label/#{@new_prescription.id}", "/patient/#{@patient.id}")
    end
  end

  def ajax_prescriptions
    # this function services the application dashboard

    prescriptions = Prescription.where("voided = ? AND quantity > amount_dispensed", false).order(created_at: :asc)
    render :text => view_context.prescriptions(prescriptions).to_json
  end

  private

  def dispense_item(inventory,prescription,dispense_amount)

    Dispensation.transaction do

      inventory.current_quantity -= dispense_amount.to_i

      if inventory.save

        prescription.amount_dispensed += dispense_amount.to_i
        prescription.save

        dispensation = Dispensation.create({:rx_id => prescription.id, :inventory_id => inventory.bottle_id,
                                            :patient_id => prescription.patient_id, :quantity => dispense_amount,
                                            :dispensation_date => Time.now})
      else
        return false
      end
    end
  end

  def get_suggestions(patient_id, drug)

    category = "PMAP"
    meds = PmapInventory.where("patient_id = ? and rxaui = ? and current_quantity > ? and voided = ?",
                               patient_id, drug, 0, false).order(expiration_date: :asc).pluck(:pap_identifier,:lot_number,
                                                                                              :expiration_date,
                                                                                              :current_quantity)

    suggestions =[]
    if meds.blank?
      category = "General"
      meds = GeneralInventory.where("rxaui = ? and current_quantity > ? and voided = ?", drug,0,
                                    false).order(expiration_date: :asc).limit(5).pluck(:gn_identifier, :lot_number,
                                                                                       :expiration_date,:current_quantity)
    end

    (meds || []).each do |item|
      suggestions << {"id" => Misc.dash_formatter(item[0]),"lot_number" => Misc.dash_formatter(item[1]),
                       "expiry_date" => (item[2].to_date.strftime('%b %d, %Y') rescue ""),"amount_remaining" => item[3]}
    end
    return [category,suggestions]
  end
end
