class DrugThresholdController < ApplicationController
  def index
    #list of drug thresholds that exist in the system

    @thresholds = DrugThreshold.where("voided = ?", false)
    @unique_items = Prescription.where("voided =?", false).pluck(:rxaui).uniq.length
    @understocked = []

    items = Hash[*GeneralInventory.find_by_sql("SELECT (SELECT RXCUI FROM RXNCONSO where RXAUI = gn.rxaui LIMIT 1) as rxcui,
                                          sum(gn.current_quantity) as current_quantity from general_inventories gn where
                                          voided = false group by rxcui").collect{|x| [x.rxcui, x.current_quantity]}.flatten(1)]

    (@thresholds || []).each do |threshold|

      if items[threshold.rxcui].blank?
        @understocked << threshold.rxcui
      else
        if items[threshold.rxcui] <= threshold.threshold
          @understocked << threshold.rxcui
        end
      end
    end
  end

  def destroy
    # function to void drug thresholds

    threshold = DrugThreshold.find(params[:id])
    threshold.update_attributes(:voided => TRUE)
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
