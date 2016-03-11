class PrescriptionController < ApplicationController
  def index
    @prescriptions = Prescription.where("voided = ? ", false).order(created_at: :asc)
  end

  def show
  end

  def edit
  end

  def destroy
    prescription = Prescription.find(params[:id])
    prescription.update_attributes(:voided => true)
    redirect_to "/prescription"
  end

  def dispense

    #First we check which inventory we are dispensing from
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
end
