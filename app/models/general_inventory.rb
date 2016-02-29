class GeneralInventory < ActiveRecord::Base
  belongs_to :rxnconso, :foreign_key => :rxaui

  before_create :complete_record

  private

  def complete_record
    self.current_quantity = self.received_quantity
  end

end
