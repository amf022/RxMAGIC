class Prescription < ActiveRecord::Base
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :provider, :foreign_key => :provider_id
  belongs_to :rxnconso, :foreign_key => :rxaui

  has_many :dispensations, :foreign_key => :rx_id
  
  def patient_name
    self.patient.fullname
  end

  def drug_name
    #this method handles the need to access the drug name associated to the inventory entry
    self.rxnconso.STR.titleize rescue ""
  end

  def has_pmap
    pmap_meds = PmapInventory.where("patient_id = ? and rxaui = ? and current_quantity > ? and voided = ?",
                                   self.patient_id, self.rxaui, 0, false).pluck(:pap_inventory_id)

    return (pmap_meds.blank? ? false : true)
  end

  def prescribed_by
    self.provider.fullname.titleize
  end

  def lot_numbers
    
    keys = self.dispensations.collect { |x| x.inventory_id.to_s }.join("','")
    
    GeneralInventory.find_by_sql("(SELECT lot_number FROM general_inventories WHERE (gn_identifier in ('#{keys}') AND
                                  voided = 0)) UNION (SELECT lot_number FROM pmap_inventories WHERE
                                  (pap_identifier in ('#{keys}') AND voided = 0))").collect { |x| x.lot_number }.join(",") rescue ""
  end
  
end
