class PatientController < ApplicationController
  def new
  end

  def create
  end

  def destroy
  end

  def show
  end

  def index
    reorders = PmapInventory.where("voided = ? AND reorder_date  BETWEEN ? AND ?",false,
                                    Date.today.strftime('%Y-%m-%d'),
                                    Date.today.advance(:months => 6).end_of_month.strftime('%Y-%m-%d')).pluck(:patient_id)


    rawPatients = Patient.where("voided = ? AND patient_id in (?)", false,
                              reorders.join(",")).pluck(:first_name, :last_name, :gender,:birthdate,:state,:city,:patient_id)

    @patients = view_context.patients(rawPatients)

  end

  def ajax_patient

    date = params[:patient][:date_of_birth].to_date.strftime("%Y")

    rawPatients = Patient.where("voided = ? AND (first_name LIKE ? OR last_name LIKE ? OR birthdate LIKE ?)",
                             false, "%#{params[:patient][:first_name]}%","%#{params[:patient][:last_name]}%",
                             "%#{date}%").pluck(:first_name, :last_name, :gender,:birthdate,:state,:city,:patient_id)


    @patients =  view_context.patients(rawPatients)

    render "index"
  end
end
