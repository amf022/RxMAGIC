class PapInventoryController < ApplicationController

  def index
    @inventory = PapInventory.where("current_quantity > 0 and voided = ?", false).order(date_received: :asc)
  end

  def show
  end

  def edit
  end

  def destroy
    #Delete an item from general inventory

    item = PapInventory.find_by_pap_identifier(params[:id])
    item.update_attributes(:voided => true)
    flash[:success] = " #{item.drug_name} #{item.lot_number} was successfully deleted."
    redirect_to "/pap_inventory"
  end
end
