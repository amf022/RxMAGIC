class PapInventoryController < ApplicationController

  def index
    @inventory = PapInventory.where("current_quantity > 0").order(date_received: :asc)
  end

  def show
  end

  def edit
  end

  def delete
  end
end
