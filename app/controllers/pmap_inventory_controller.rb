class PmapInventoryController < ApplicationController

  def index
    @inventory = PmapInventory.where("current_quantity > 0 and voided = ?", false).order(date_received: :asc)

    @in_stock = PmapInventory.select("patient_id, rxaui, count(rxaui) as count").where("current_quantity > 0
                                      and voided = ?",false).group(:patient_id,:rxaui).length

    @aboutToExpire = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                                            Date.today.strftime('%Y-%m-%d'),
                                            Date.today.advance(:months => 2).end_of_month.strftime('%Y-%m-%d')).length

    @expired = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ",
                                      false,0, Date.today.strftime('%Y-%m-%d')).pluck(:pap_identifier).length

  end

  def show
  end

  def edit

    @entry = PmapInventory.find_by_pap_identifier(params[:pmap_inventory][:pmap_inventory_id])

    if @entry.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = ["Item not found"]
    else
      if (@entry.received_quantity - @entry.current_quantity) > params[:pmap_inventory][:amount_received].to_i
        flash[:errors] = {} if flash[:errors].blank?
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

    item = PmapInventory.void_item(params[:pmap_inventory][:pmap_id],params[:pmap_inventory][:reason])
    if item.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = ["Item was not found"]
    elsif item.errors.blank?
      flash[:success] = "#{item.drug_name} #{item.lot_number} was successfully deleted."
    else
      flash[:errors] = item.errors
    end

    redirect_to "/pmap_inventory"
  end

  def move_inventory
    #Move pmap item to general inventory

    result = PmapInventory.move_to_general(params[:id])

    if result.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = "Item was not found"
    elsif result.errors.blank?
      flash[:success] = " #{result.drug_name} #{result.lot_number} was successfully moved to general inventory."
    else
      flash[:errors] = result.errors
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

  def expired_items
    @expired = PmapInventory.select("patient_id, rxaui,pap_identifier, date_received, expiration_date,current_quantity").where("voided = ? AND current_quantity > ? AND expiration_date <= ? ",
                                   false,0, Date.today.strftime('%Y-%m-%d'))

  end

  def about_to_expire
    @aboutToExpire = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                                         Date.today.strftime('%Y-%m-%d'),
                                         Date.today.advance(:months => 2).end_of_month.strftime('%Y-%m-%d'))

  end
end
