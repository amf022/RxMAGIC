class PapInventory < ActiveRecord::Base
  belongs_to :rxnconso, :foreign_key => :rxaui
  belongs_to :patient, :foreign_key => :patient_id

  before_create :complete_record

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

  private

  def complete_record
    self.current_quantity = self.received_quantity
    self.date_received = Date.today
    last_id = PapInventory.order(pap_inventory_id: :desc).first.id rescue "0"
    next_number = (last_id.to_i+1).to_s.rjust(7,"0")
    check_digit = calculate_check_digit(next_number)
    self.pap_identifier = "PM#{next_number}#{check_digit}"
  end
end
