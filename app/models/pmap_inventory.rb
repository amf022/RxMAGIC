class PmapInventory < ActiveRecord::Base
  belongs_to :rxnconso, :foreign_key => :rxaui
  belongs_to :patient, :foreign_key => :patient_id

  before_create :complete_record
  before_save :complete_record

  validates :lot_number, :presence => true
  validates :reorder_date, :presence => true
  validates :received_quantity, :presence => true
  validates :received_quantity, :numericality => { :only_integer => true }
  validates :received_quantity, :numericality => { :greater_than => 0 }
  validates_associated :rxnconso

  include Misc

  def patient_name
    self.patient.fullname
  end

  def drug_name
    #this method handles the need to access the drug name associated to the inventory entry

    self.rxnconso.STR
  end

  def made_by
    self.manufacturer.blank? ? "Unknown" : self.manufacturer
  end

  def bottle_id
    return self.pap_identifier
  end

  private

  def complete_record
    self.current_quantity = self.received_quantity if self.current_quantity.blank?
    self.date_received = Date.today if self.date_received.blank?
    self.manufacturer = "Unknown" if self.manufacturer.blank?
    unless !self.pap_identifier.blank?
      last_id = PmapInventory.order(pap_inventory_id: :desc).first.id rescue "0"
      next_number = (last_id.to_i+1).to_s.rjust(6,"0")
      check_digit = calculate_check_digit(next_number)
      self.pap_identifier = "P#{next_number}#{check_digit}"
    end
  end
end
