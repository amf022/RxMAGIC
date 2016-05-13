class InventoryController < ApplicationController

  include Misc

  def print_bottle_barcode
    #This function prints bottle barcode labels for both inventory types

    inventory = params[:id].match(/g/i)? "General" : "PMAP"

    entry = (inventory == "PMAP"? PmapInventory.where("pap_identifier = ?", params[:id]).first : GeneralInventory.where("gn_identifier = ?", params[:id]).first)

    if ((Time.now - entry.created_at) < 240)
      flash[:success] = "#{entry.drug_name} was successfully added to inventory."
    end

    print_string = create_bottle_label(entry.drug_name,params[:id],entry.expiration_date,entry.lot_number,inventory, inventory == "PMAP"? entry.patient_name : nil)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{entry.lot_number}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def void_inventory_item
    #Delete an expired item from inventory

    if params[:bottle_id].match(/g/i)
      item = GeneralInventory.void_item(params[:bottle_id],"Medication has expired")
    else
      pmap_check = PmapInventory.where("pap_identifier = ? AND voided = ?",params[:bottle_id], false).pluck(:lot_number)

      if pmap_check.blank?
        item = GeneralInventory.void_item(params[:bottle_id],"Medication has expired")
      else
        item = PmapInventory.void_item(params[:bottle_id],"Medication has expired")
      end

    end

    if item.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = "Item was not found"
    elsif item.errors.blank?
      flash[:success] = "#{item.drug_name} #{item.lot_number} was successfully deleted."
      News.resolve(params[:bottle_id],"expired item","Item discarded")
    else
      flash[:errors] = item.errors
    end

    redirect_to "/"
  end

  def move_inventory_item

    result = PmapInventory.move_to_general(params[:bottle_id])

    if result.blank?
      flash[:errors] = {} if flash[:errors].blank?
      flash[:errors][:missing] = "Item was not found"
    elsif result.errors.blank?
      flash[:success] = " #{result.drug_name} #{result.lot_number} was successfully moved to general inventory."
      News.resolve(params[:bottle_id],"under utilized item","Moved to general inventory")
    else
      flash[:errors] = result.errors
    end

    redirect_to "/"
  end
end
