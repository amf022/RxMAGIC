class PmapInventoryController < ApplicationController

  def index
    @inventory = PmapInventory.where("current_quantity > 0 and voided = ?", false).order(date_received: :asc)
  end

  def show
  end

  def edit
  end

  def create

    @new_stock_entry = PmapInventory.new

    @new_stock_entry.lot_number = params[:pmap_inventory][:lot_number].upcase
    @new_stock_entry.expiration_date = params[:pmap_inventory][:expiration_date].to_date rescue nil
    @new_stock_entry.reorder_date = params[:pmap_inventory][:reorder_date].to_date rescue nil
    @new_stock_entry.received_quantity = params[:pmap_inventory][:received_quantity]
    @new_stock_entry.rxaui = Rxnconso.where("STR = ?", params[:pmap_inventory][:item]).first.RXAUI rescue nil
    @new_stock_entry.patient_id = params[:pmap_inventory][:patient_id]

    PmapInventory.transaction do
      @new_stock_entry.save
    end

    if @new_stock_entry.errors.blank?
      #print barcode for new bottles
      if params[:pmap_inventory][:inventory_id].blank?
        print_and_redirect("/print_bottle_barcode/#{@new_stock_entry.pap_identifier}", "/patient/#{params[:pmap_inventory][:patient_id]}")
      else
        flash[:success] = "#{params[:pmap_inventory][:item]} (Lot #: #{@new_stock_entry.lot_number}) was successfully updated."
        redirect_to "/patient/#{params[:pmap_inventory][:patient_id]}"
      end
    else
      flash[:errors] = @new_stock_entry.errors
      redirect_to "/patient/#{params[:pmap_inventory][:patient_id]}"
    end
  end

  def destroy
    #Delete an item from general inventory

    item = PmapInventory.find_by_pap_identifier(params[:id])
    item.update_attributes(:voided => true, :void_reason => params[:reason])
    flash[:success] = " #{item.drug_name} #{item.lot_number} was successfully deleted."
    redirect_to "/pmap_inventory"
  end
end
