class GeneralInventory < ActiveRecord::Base
  belongs_to :rxnconso, :foreign_key => :rxaui
  before_create :complete_record
  validates :lot_number, :presence => true
  validates :rxaui, :presence => true
  validates :expiration_date, :presence => true
  validates :received_quantity, :presence => true

  private

  def complete_record
    self.current_quantity = self.received_quantity
    self.date_received = Time.now
    self.gn_identifier = "GN-#{rand(9999).to_s.rjust(5,'0')}"
  end

end
