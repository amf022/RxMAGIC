class PmapInventoryController < ApplicationController

  def index
    @inventory = PmapInventory.where("current_quantity > 0 and voided = ?", false).order(date_received: :asc)
  end

  def show
  end

  def edit

    @entry = PmapInventory.find_by_pap_identifier(params[:pmap_inventory][:pmap_inventory_id])

    if @entry.blank?
      flash[:error] = {} if flash[:error].blank?
      flash[:error][:missing] = "Item not found"
    else
      if (@entry.received_quantity - @entry.current_quantity) > params[:pmap_inventory][:amount_received].to_i
        flash[:error] = {} if flash[:error].blank?
        flash[:errors]["counts"] = [" The number of items that have already been dispensed from this bottle is more than the received quantity."]
      else
        @entry.current_quantity = params[:pmap_inventory][:amount_received].to_i - (@entry.received_quantity - @entry.current_quantity)
        @entry.lot_number = params[:pmap_inventory][:lot_number]
        @entry.expiration_date = params[:pmap_inventory][:expiry_date].to_date rescue nil
        @entry.manufacturer = params[:pmap_inventory][:manufacturer]
        if @entry.save
          flash[:success] = "#{@entry.bottle_id}  was successfully updated."
        else
          flash[:errors] = @entry.errors
        end
      end
    end

    redirect_to "/pmap_inventory"
  end

  def create

    @new_stock_entry = PmapInventory.new

    @new_stock_entry.lot_number = params[:pmap_inventory][:lot_number].upcase
    @new_stock_entry.expiration_date = params[:pmap_inventory][:expiration_date].to_date rescue nil
    @new_stock_entry.reorder_date = params[:pmap_inventory][:reorder_date].to_date rescue nil
    @new_stock_entry.manufacturer = params[:pmap_inventory][:manufacturer]
    @new_stock_entry.received_quantity = params[:pmap_inventory][:received_quantity]
    @new_stock_entry.current_quantity = params[:pmap_inventory][:received_quantity]
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
    #Delete an item from pmap inventory

    item = PmapInventory.find_by_pap_identifier(params[:pmap_inventory][:pmap_id])
    item.voided = true
    item.manufacturer = "Unknown" if item.manufacturer.blank?
    item.void_reason =  params[:pmap_inventory][:reason]
    if item.save
      flash[:success] = " #{item.drug_name} #{item.lot_number} was successfully deleted."
    else
      flash[:errors] = item.errors
    end

    redirect_to "/pmap_inventory"
  end

  def move_inventory
    #Move pmap item to general inventory


    item = PmapInventory.find_by_pap_identifier(params[:id])
    item.voided = true
    item.void_reason = "Moved to general inventory"
    item.manufacturer = "Unknown" if item.manufacturer.blank?

    if item.save
      new_stock_entry = GeneralInventory.new
      new_stock_entry.lot_number = item.lot_number.upcase
      new_stock_entry.expiration_date = item.expiration_date rescue nil
      new_stock_entry.received_quantity = item.current_quantity
      new_stock_entry.rxaui = item.rxaui
      new_stock_entry.gn_identifier= item.pap_identifier

      if new_stock_entry.save
        flash[:success] = " #{item.drug_name} #{item.lot_number} was successfully moved to general inventory."
      else
        flash[:errors] = new_stock_entry.errors
      end
    else
      flash[:errors] = item.errors
    end

    redirect_to "/pmap_inventory"
  end

  def reorders
    reorders = PmapInventory.where("reorder_date between ? AND ? AND voided = ?",
                                   Date.today.beginning_of_week.strftime("%Y-%m-%d"),
                                   Date.today.end_of_week.strftime("%Y-%m-%d"),false )

    @reorders = view_context.reorders(reorders)
  end

  def detailed_search
    reorders = PmapInventory.where("reorder_date between ? AND ? AND voided = ?",
                                   params[:pmap_inventory][:startDate].to_date.strftime("%Y-%m-%d"),
                                   params[:pmap_inventory][:endDate].to_date.strftime("%Y-%m-%d"),false )

    @reorders = view_context.reorders(reorders)

    render "reorders"

  end
end
