class Dispensation < ActiveRecord::Base
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :prescription, :foreign_key => :rx_id

  def inventory
    entry = (self.inventory_id.match(/gn/i)? GeneralInventory.where("gn_identifier = ?", self.inventory_id).first : PapInventory.where("pap_identifier = ?", self.inventory_id).first)
  end
end
