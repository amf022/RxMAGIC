class Dispensation < ActiveRecord::Base
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :prescription, :foreign_key => :rx_id

  def inventory
    return (self.inventory_id.match(/g/i)? GeneralInventory.where("gn_identifier = ?", self.inventory_id).first : PapInventory.where("pap_identifier = ?", self.inventory_id).first)
  end


  def drug_name
    inventory.rxnconso.STR
  end
end
