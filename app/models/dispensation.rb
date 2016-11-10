class Dispensation < ActiveRecord::Base
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :prescription, :foreign_key => :rx_id

  def inventory
    return (self.inventory_id.match(/g/i)? GeneralInventory.where("gn_identifier = ?", self.inventory_id).first : PmapInventory.where("pap_identifier = ?", self.inventory_id).first)
  end

  def drug_name
    inventory.rxnconso.STR.humanize.gsub(/\b('?[a-z])/) { $1.capitalize } rescue ""
  end

  def self.void(id)
    dispensation = Dispensation.find(id)
    Dispensation.transaction do
      bottle = dispensation.inventory_id.match(/g/i)? "General" : "PMAP"

      if bottle == "PMAP"
        item = PmapInventory.where("pap_identifier = ? and voided = ?", dispensation.inventory_id,false).first
        bottle = (item.blank? ? "General" : "PMAP")
      end

      if bottle == "General"
        item = GeneralInventory.where("gn_identifier = ? AND voided = ?", dispensation.inventory_id, false).first
      end

      if item.blank?
        return dispensation
      else
        prescription = dispensation.prescription

        item.current_quantity += dispensation.quantity
        item.save

        dispensation.voided = true
        dispensation.save

        prescription.amount_dispensed -= dispensation.quantity
        prescription.save
      end
    end
    return dispensation
  end
end
