class DrugThresholdController < ApplicationController
  def index
    @thresholds = DrugThreshold.where("voided = ?", false)
  end

  def destroy
    threshold = DrugThreshold.find(params[:id])
    threshold.update_attributes(:voided => TRUE)
    flash[:success] = " #{threshold.drug_name} was successfully deleted."
    redirect_to "/drug_threshold"
  end

  def create
    concept = Rxnconso.where("STR = ?", params[:drug_threshold][:item]).first.RXAUI rescue nil

    if concept.blank?
      flash[:error] = [["Could not create new threshold. Item not recognized"]]
    else
      new_drug_threshold = DrugThreshold.where(rxaui: concept).first_or_initialize
      new_drug_threshold.threshold = params[:drug_threshold][:item_threshold]
      new_drug_threshold.voided = false
      DrugThreshold.transaction do
        new_drug_threshold.save
      end

      if new_drug_threshold.errors.blank?
        flash[:success] = "New threshold for #{new_drug_threshold.drug_name} created"
      else
        flash[:error] = new_drug_threshold.errors
      end
    end

    redirect_to "/drug_threshold"
  end
end
