class InventoryController < ApplicationController

  include Misc

  def print_bottle_barcode
    #This function prints bottle barcode labels for both inventory types

    inventory = params[:id].match(/gn/i)? "General" : "PMAP"

    entry = (inventory == "PMAP"? PapInventory.where("pap_identifier = ?", params[:id]).first : GeneralInventory.where("gn_identifier = ?", params[:id]).first)

    if ((Time.now - entry.created_at) < 240)
      flash[:success] = "#{entry.drug_name} was successfully added to inventory."
    end

    print_string = create_bottle_label(entry.drug_name,params[:id],entry.expiration_date,entry.lot_number,inventory, inventory == "PMAP"? entry.patient_name : nil)
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false, :filename=>"#{entry.lot_number}#{rand(10000)}.lbl", :disposition => "inline")
  end
end
