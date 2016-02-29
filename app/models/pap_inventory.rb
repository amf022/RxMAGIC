class PapInventory < ActiveRecord::Base
  belongs_to :rxnconso, :foreign_key => :rxaui
  belongs_to :patient, :foreign_key => :patient_id

  before_create :complete_record

  def patient_name
    self.patient.fullname
  end

  private

  def complete_record
    self.current_quantity = self.received_quantity
  end
end
