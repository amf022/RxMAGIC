class DrugThresholdController < ApplicationController
  def index
    @thresholds = DrugThreshold.where("voided = ?", false)
  end

  def destroy
    threshold = DrugThreshold.find(params[:id])
    threshold.update_attributes(:voided => false)
    flash[:success] = " #{threshold.drug_name} was successfully deleted."
    redirect_to "/drug_threshold"
  end

  def create
    new_drug_threshold = DrugThreshold.new
    new_drug_threshold.threshold = params[:drug_threshold][:item_threshold]
    new_drug_threshold.rxaui = Rxnconso.where("STR = ?", params[:drug_threshold][:item]).first.RXAUI rescue nil

    DrugThreshold.transaction do
      new_drug_threshold.save
    end

    if new_drug_threshold.errors.blank?
      flash[:success] = "New threshold for #{new_drug_threshold.drug_name} created"
    else
      flash[:error] = new_drug_threshold.errors
    end

    redirect_to "/drug_threshold"
  end
end
