class GeneralInventory < ActiveRecord::Base
  belongs_to :rxnconso, :foreign_key => :rxaui
  before_create :complete_record

  validates :lot_number, :presence => true
  validates :expiration_date, :presence => true
  validates :received_quantity, :presence => true
  validates :received_quantity, :numericality => { :only_integer => true }
  validates :received_quantity, :numericality => { :greater_than => 0 }
  validates_associated :rxnconso

  include Misc

  private

  def complete_record
    self.current_quantity = self.received_quantity
    self.date_received = Date.today
    last_id = GeneralInventory.order(gn_inventory_id: :desc).first.id rescue "0"
    next_number = (last_id.to_i+1).to_s.rjust(7,"0")
    check_digit = calculate_check_digit(next_number)
    self.gn_identifier = "GN#{next_number}#{check_digit}"
  end

end
