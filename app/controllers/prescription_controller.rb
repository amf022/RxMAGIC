class PrescriptionController < ApplicationController

  def index
    # This function serves the main table for prescriptions
    @prescriptions = Prescription.select("directions, provider_id,quantity,rxaui,
                                          patient_id,rx_id").where("voided = ? AND quantity > amount_dispensed",false).order(date_prescribed: :asc)

    @items = Hash[*Rxnconso.where("rxaui in (?)", @prescriptions.collect{|x| x.rxaui}.uniq).pluck(:rxaui,:STR).flatten(1)]

    @providers = Provider.where("provider_id in (?)", @prescriptions.collect{|x| x.provider_id}.uniq).pluck(:provider_id,:first_name, :last_name).inject({}) do |result, element|
      result[element[0]] = element[1] + " " + element[2] rescue " "
      result
    end

    @patients = Patient.where("patient_id in (?)", @prescriptions.collect{|x| x.patient_id}.uniq).pluck(:patient_id,:first_name, :last_name).inject({}) do |result, element|
      result[element[0]] = element[1] + " " + element[2] rescue " "
      result
    end
  end

  def show
    @prescription = Prescription.where(:rx_id => params[:id]).first rescue nil

    if @prescription.blank?
      redirect_to "/prescription"
    end

    @category, @suggestions = get_suggestions(@prescription.patient_id, @prescription.rxnconso.RXCUI)

  end

  def edit

    @prescription = Prescription.find(params[:edit_prescription][:prescription_id]) rescue nil
    if @prescription.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = "Prescription was not found"
      redirect_to "/prescriptions"
    else
      @prescription.quantity = params[:edit_prescription][:quantity]
      @prescription.save
      if @prescription.quantity <= @prescription.amount_dispensed
        News.resolve(params[:dispensation][:prescription],"new prescription","prescritption filled")
        print_and_redirect("/print_dispensation_label/#{@prescription.id}", "/prescription/#{@prescription.id}")
      else
        redirect_to @prescription
      end
    end
  end

  def destroy
    # This function voids a prescription and marks it as deleted

    prescription = Prescription.find(params[:id])
    prescription.update_attributes(:voided => true)
    if prescription.errors.blank?
      news = News.where("refers_to = ? AND resolved = ?", params[:id], false).first
      unless news.blank?
        news.resolved = true
        news.resolution = "Rx was cancelled"
        news.date_resolved= Date.today
        news.save
        logger.info "Prescription #{params[:id]} was voided by #{current_user.username}"
      end
    end
    redirect_to "/prescription"
  end

  def ajax_prescriptions
    # this function services the application dashboard

    prescriptions = Prescription.where("voided = ? AND quantity > amount_dispensed", false).order(date_prescribed: :asc)
    render :text => view_context.prescriptions(prescriptions).to_json
  end

  private
  def get_suggestions(patient_id, drug)

    options = Rxnconso.where("RXCUI = ? ",drug).pluck(:RXAUI)
    category = "PMAP"
    meds = PmapInventory.where("patient_id = ? and rxaui in (?) and current_quantity > ? and voided = ?",
                               patient_id, options, 0, false).order(expiration_date: :asc).pluck(:pap_identifier,:lot_number,
                                                                                              :expiration_date,
                                                                                              :current_quantity)

    suggestions =[]
    if meds.blank?
      category = "General"
      meds = GeneralInventory.where("rxaui in (?) and current_quantity > ? and voided = ?", options,0,
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
