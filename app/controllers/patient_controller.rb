class PatientController < ApplicationController
  def new
  end

  def create
  end

  def destroy
  end

  def show
    @patient = Patient.find(params[:id])
    @history = Dispensation.where("patient_id = ? and voided = ?",params[:id],false).limit(10)
    rawPmapMeds = PmapInventory.where("voided = ? AND patient_id = ? AND current_quantity > ?", false,params[:id],0)
    @pmap_meds = {}
    (rawPmapMeds || []).each do |med|
      @pmap_meds[med.made_by] = [] if @pmap_meds[med.made_by].blank?
      @pmap_meds[med.made_by] << ["#{med.drug_name}", med.current_quantity]
    end
    @providers = Provider.all.collect{|x| "#{x.first_name.squish rescue ""} #{x.last_name.squish  rescue ""}"}.uniq
  end

  def index
    reorders = PmapInventory.where("voided = ? AND reorder_date  BETWEEN ? AND ?",false,
                                    Date.today.strftime('%Y-%m-%d'),
                                    Date.today.advance(:months => 2).end_of_month.strftime('%Y-%m-%d')).pluck(:patient_id)


    rawPatients = Patient.where("voided = ? AND patient_id in (?)", false,
                              reorders).pluck(:first_name, :last_name, :gender,:birthdate,:state,:city,:patient_id)

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

  def toggle_language_preference
    patient = Patient.find(params[:id])
    unless patient.blank?
      patient.language = (patient.language == "ENG"? "ESP" : "ENG")
      patient.save
      logger.info "Patient #{params[:id]} language preference switched by #{current_user.username}"
    end
    render :text => "done"
  end
end
