class GeneralInventoryController < ApplicationController
  def index
    @inventory = GeneralInventory.where("current_quantity > 0").order(date_received: :asc)
  end

  def new

  end

  def edit

  end

  def create

  end
end
