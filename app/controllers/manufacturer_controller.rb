class ManufacturerController < ApplicationController
  def index
    @manufacturers = Manufacturer.where(voided: false)
  end

  def create

    new_manufacturer = Manufacturer.where(name: params[:manufacturer][:company_name],
                                          has_pmap: params[:manufacturer][:has_pmap]).first_or_initialize

    new_manufacturer.save
    if new_manufacturer.errors.blank?
      flash[:success] = "#{new_manufacturer.name.titleize} was successfully added."
    else
      flash[:errors] = new_manufacturer.errors
    end

    redirect_to "/manufacturer"

  end

  def new

  end

  def edit

  end

  def update
    new_manufacturer = Manufacturer.find(params[:edit_manufacturer][:mfn_id])

    unless new_manufacturer.blank?
      new_manufacturer.name = params[:edit_manufacturer][:company_name]
      new_manufacturer.has_pmap = params[:edit_manufacturer][:has_pmap]
      new_manufacturer.save
      if new_manufacturer.errors.blank?
        flash[:success] = "#{new_manufacturer.name.titleize} was successfully updated."
      else
        flash[:errors] = new_manufacturer.errors
      end
    end

    redirect_to "/manufacturer"

  end

  def destroy
    # function to void drug thresholds

    company = Manufacturer.find(params[:id])
    company.update_attributes(:voided => TRUE)
    if company.errors.blank?
      flash[:success] = "#{company.name.titleize} was successfully deleted."
    else
      flash[:errors] = company.errors
    end

    redirect_to "/manufacturer"
  end
end
