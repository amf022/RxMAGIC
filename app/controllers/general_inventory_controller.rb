class GeneralInventoryController < ApplicationController
  def index
    @inventory = GeneralInventory.where("current_quantity > 0").order(date_received: :asc)
  end

  def new

  end

  def edit

  end

  def create
    new_stock_entry = GeneralInventory.new
    new_stock_entry.lot_number = params[:lot_number]
    new_stock_entry.expiration_date = params[:expiration_date]
    new_stock_entry.received_quantity = params[:quantity_received]
    new_stock_entry.rxaui = random_drug
    new_stock_entry.save
  end
end
