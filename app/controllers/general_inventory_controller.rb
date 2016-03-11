class GeneralInventoryController < ApplicationController
  def index
    @inventory = GeneralInventory.where("current_quantity > 0").order(date_received: :asc)
  end

  def new

  end

  def edit

  end

  def create

    # Create a new record for general inventory

    @new_stock_entry = GeneralInventory.new
    @new_stock_entry.lot_number = params[:general_inventory][:lot_number].upcase
    @new_stock_entry.expiration_date = params[:general_inventory][:expiration_date].to_date rescue nil
    @new_stock_entry.received_quantity = params[:general_inventory][:received_quantity]
    @new_stock_entry.rxaui = Rxnconso.where("STR = ?", params[:general_inventory][:item]).first.RXAUI rescue nil


    GeneralInventory.transaction do
      @new_stock_entry.save
    end

    flash[:errors] = @new_stock_entry.errors


    redirect_to "/general_inventory"



  end

end
