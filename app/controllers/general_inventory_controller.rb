class GeneralInventoryController < ApplicationController
  def index
    @inventory = GeneralInventory.where("current_quantity > 0 AND voided = ?", false).order(date_received: :asc)

    thresholds = DrugThreshold.where("voided = ?", false).pluck(:rxaui, :threshold)

    @expired = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ", false,0, Date.today.strftime('%Y-%m-%d')).pluck(:gn_identifier)

    @aboutToExpire = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                                            Date.today.strftime('%Y-%m-%d'),
                                            Date.today.advance(:months => 6).end_of_month.strftime('%Y-%m-%d'))

    @underStocked = []

    @wellStocked = []


    items = GeneralInventory.where("voided = ?", false).group(:rxaui).sum(:current_quantity)

    (thresholds || []).each do |threshold|

      if items[threshold[0]].blank?
        @underStocked << threshold[0]
      elsif items[threshold[0]] <= threshold[1]
        @underStocked << threshold[0]
      else
        @wellStocked << threshold[0]
      end
    end

  end

  def new

  end

  def edit

  end

  def destroy
    #Delete an item from general inventory

    item = GeneralInventory.find_by_gn_identifier(params[:general_inventory][:gn_id])
    item.voided = true
    item.void_reason = (params[:general_inventory][:specific_reason].blank? ? params[:general_inventory][:reason] : "#{params[:general_inventory][:specific_reason]} (#{params[:pmap_inventory][:reason]})")
    if item.save
      flash[:success] = " #{item.drug_name} #{item.lot_number} was successfully deleted."
    else
      flash[:errors] = item.errors
    end

    redirect_to "/general_inventory"
  end

  def create

    # Create a new record for general inventory

    if params[:general_inventory][:inventory_id].blank?
      @new_stock_entry = GeneralInventory.new
      @new_stock_entry.rxaui = Rxnconso.where("STR = ?", params[:general_inventory][:item]).first.RXAUI rescue nil
      name = params[:general_inventory][:item]
    else
      @new_stock_entry = GeneralInventory.find(params[:general_inventory][:inventory_id])
      name = @new_stock_entry.drug_name
      if (@new_stock_entry.received_quantity - @new_stock_entry.current_quantity) > params[:general_inventory][:received_quantity].to_f
        flash[:errors][:counts] = [" The number of items that have already been dispensed from this bottle is more than the received quantity."]
      else
          @new_stock_entry.current_quantity = params[:general_inventory][:received_quantity].to_f - (@new_stock_entry.received_quantity - @new_stock_entry.current_quantity)
      end

    end

    @new_stock_entry.lot_number = params[:general_inventory][:lot_number].upcase
    @new_stock_entry.expiration_date = params[:general_inventory][:expiration_date].to_date rescue nil
    @new_stock_entry.received_quantity = params[:general_inventory][:received_quantity]

    GeneralInventory.transaction do
      @new_stock_entry.save
    end

    if @new_stock_entry.errors.blank?
      #print barcode for new bottles
      if params[:general_inventory][:inventory_id].blank?
        print_and_redirect("/print_bottle_barcode/#{@new_stock_entry.gn_identifier}", "/general_inventory")
      else
        flash[:success] = "#{name} (Lot #: #{@new_stock_entry.lot_number}) was successfully updated."
        redirect_to "/general_inventory"
      end
    else
      flash[:errors] = @new_stock_entry.errors
      redirect_to "/general_inventory"
    end
  end

  def expired_items
    #This funtion retrieves all the expired items

    items = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ", false,0, Date.today.strftime('%Y-%m-%d'))

    @expired = view_context.expired_items(items)
  end
end
