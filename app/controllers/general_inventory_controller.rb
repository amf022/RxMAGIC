class GeneralInventoryController < ApplicationController
  def index

  end

  def new
    @general_inventory = GeneralInventory.new

  end
end
