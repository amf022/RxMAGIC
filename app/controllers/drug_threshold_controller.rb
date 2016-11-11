class DrugThresholdController < ApplicationController
  def index
    #list of drug thresholds that exist in the system

    @thresholds = DrugThreshold.where("voided = ?", false)
    @unique_items = Prescription.where("voided =?", false).pluck(:rxaui).uniq.length

    thresholds = Misc.calculate_gn_thresholds

    @underStocked =[]

    (thresholds || []).each do |id, details|
      if details["count"] <= details["threshold"]
        @underStocked << {"drug_name" => details["name"], "threshold" => details["threshold"],
                          "available" => details["count"], "id" => id}
      end
    end

  end

  def destroy
    # function to void drug thresholds

    threshold = DrugThreshold.find(params[:id])
    threshold.update_attributes(:voided => TRUE)
    if threshold.errors.blank?
      DrugThresholdSet.void_drug_set(params[:id])
    end
    flash[:success] = "PAR level for #{threshold.drug_name} was successfully deleted."
    redirect_to "/drug_threshold"
  end

  def create
    #this function creates and edits drug thresholds

    if params[:drug_threshold][:drug_threshold_id].blank?
      #Create new threshold

      concept = Rxnconso.where("STR = ?", params[:drug_threshold][:item]).first rescue nil

      if concept.blank?
        flash[:errors] = {} if flash[:errors].blank?
        flash[:errors][:item_name] = [" not recognized"]
      else
        new_drug_threshold = DrugThreshold.where(rxcui: concept.RXCUI).first_or_initialize
        new_drug_threshold.rxaui = concept.RXAUI
        new_drug_threshold.threshold = params[:drug_threshold][:item_threshold]
        new_drug_threshold.voided = false
      end
    else
      #this code block updates an existing drug threshold
      new_drug_threshold = DrugThreshold.find(params[:drug_threshold][:drug_threshold_id])
      new_drug_threshold.threshold = params[:drug_threshold][:item_threshold]
      new_drug_threshold.voided = false
    end

    unless new_drug_threshold.blank?
      DrugThreshold.transaction do
        new_drug_threshold.save
        if params[:drug_threshold][:drug_threshold_id].blank?
            DrugThresholdSet.create_new_set(new_drug_threshold.rxcui, new_drug_threshold.id)
        end
      end

      if new_drug_threshold.errors.blank?
        flash[:success] = "New PAR level for #{new_drug_threshold.drug_name} created"
      else
        flash[:errors] = new_drug_threshold.errors
      end
    end

    redirect_to "/drug_threshold"
  end

  def unique_prescriptions
    #Function to list all drugs that have ever been prescribed

    unique_items = Prescription.where("voided =?", false).pluck(:rxaui).uniq
    terms = Rxnconso.select("STR,RXAUI").where("RXAUI in (?)", unique_items)
    @items = []
    (terms || []).each do |term|
      @items << {
          "drug_name" => term.STR,
          "threshold" => term.threshold
      }

    end
  end
end
