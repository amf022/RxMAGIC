class Prescription < ActiveRecord::Base
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :provider, :foreign_key => :provider_id
  belongs_to :rxnconso, :foreign_key => :rxaui

  def patient_name
    self.patient.fullname
  end

  def drug_name
    #this method handles the need to access the drug name associated to the inventory entry
    self.rxnconso.STR
  end

  def has_pmap
    pmap_meds = PapInventory.where("patient_id = ? and rxaui = ? and current_quantity = ? and voided = ?",
                                   self.patient_id, self.rxaui, 0, false)

    return (pmap_meds.blank? ? false : true)
  end

  def prescribed_by
    self.provider.fullname
  end
end
