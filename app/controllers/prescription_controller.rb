class PrescriptionController < ApplicationController
  def index
    # This function serves the main table for prescriptions

    @prescriptions = Prescription.where("voided = ? ", false).order(created_at: :asc)
  end

  def show
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
        PapInventory.transaction do
          item = PapInventory.where("pap_identifier = ? ", params[:bottle_id]).lock(true).first
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

    prescriptions = Prescription.where("voided = ?", false).order(date_prescribed: :desc).limit(20)
    render :text => view_context.prescriptions(prescriptions).to_json
  end
end
