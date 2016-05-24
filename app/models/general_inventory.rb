class GeneralInventory < ActiveRecord::Base
  belongs_to :rxnconso, :foreign_key => :rxaui
  before_create :complete_record

  validates :lot_number, :presence => true
  validates :expiration_date, :presence => true
  validates :received_quantity, :presence => true
  validates :current_quantity, :presence => true
  validates :received_quantity, :numericality => { :only_integer => true }
  validates :received_quantity, :numericality => { :greater_than => 0 }
  validates :current_quantity, :numericality => { :only_integer => true }
  validates :current_quantity, :numericality => { :greater_than => -1 }
  validates_associated :rxnconso

  include Misc

  def drug_name
    #this method handles the need to access the drug name associated to the inventory entry

    self.rxnconso.STR rescue ""
  end

  def bottle_id
    return self.gn_identifier
  end

  def self.void_item(bottle_id, reason)
    item = GeneralInventory.where("gn_identifier = ? and voided = ?",bottle_id, false).first
    unless item.blank?
      item.voided = true
      item.void_reason = reason
      item.save
      return item
    end

    return false
  end
  private

  def complete_record
    self.current_quantity = self.received_quantity
    self.date_received = Date.today
    unless !self.gn_identifier.blank?
      last_id = GeneralInventory.order(gn_inventory_id: :desc).first.id rescue "0"
      next_number = (last_id.to_i+1).to_s.rjust(6,"0")
      check_digit = calculate_check_digit(next_number)
      self.gn_identifier = "G#{next_number}#{check_digit}"
    end
  end
end
