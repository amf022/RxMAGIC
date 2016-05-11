class DrugThresholdController < ApplicationController
  def index
    @thresholds = DrugThreshold.where("voided = ?", false)
    @unique_items = Prescription.where("voided =?", false).pluck(:rxaui).uniq.length
    @understocked = []

    items = GeneralInventory.where("voided = ?", false).group(:rxaui).sum(:current_quantity)

    (@thresholds || []).each do |threshold|

      if items[threshold.rxaui].blank?
        @understocked << threshold.rxaui
      else
        if items[threshold.rxaui] <= threshold.threshold
          @understocked << threshold.rxaui
        end
      end
    end
  end

  def destroy
    threshold = DrugThreshold.find(params[:id])
    threshold.update_attributes(:voided => TRUE)
    flash[:success] = "Threshold for #{threshold.drug_name} was successfully deleted."
    redirect_to "/drug_threshold"
  end

  def create
    #this function creates and edits drug thresholds

    if params[:drug_threshold][:drug_threshold_id].blank?
      #Create new threshold

      concept = Rxnconso.where("STR = ?", params[:drug_threshold][:item]).first.RXAUI rescue nil

      if concept.blank?
        flash[:errors] = {} if flash[:errors].blank?
        flash[:errors][:item_name] = [" not recognized"]
      else
        new_drug_threshold = DrugThreshold.where(rxaui: concept).first_or_initialize
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
        flash[:success] = "New threshold for #{new_drug_threshold.drug_name} created"
      else
        flash[:errors] = new_drug_threshold.errors
      end
    end
    
    redirect_to "/drug_threshold"
  end

  def unique_prescriptions
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
