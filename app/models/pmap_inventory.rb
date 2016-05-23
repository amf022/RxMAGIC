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
  validates :current_quantity, :presence => true
  validates :current_quantity, :numericality => { :only_integer => true }
  validates :current_quantity, :numericality => { :greater_than => -1 }
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

  def self.void_item(bottle_id,reason)
    item = PmapInventory.where("pap_identifier = ? and voided = ?",bottle_id, false).first
    unless item.blank?
      item.voided = true
      item.manufacturer = "Unknown" if item.manufacturer.blank?
      item.void_reason = reason
      item.save
      return item
    end
    return false
  end

  def self.move_to_general(bottle_id)
    item = PmapInventory.where("pap_identifier = ? AND voided = ?",bottle_id,false).first

    unless item.blank?
      PmapInventory.transaction do
        item.voided = true
        item.void_reason = "Moved to general inventory"
        item.manufacturer = "Unknown" if item.manufacturer.blank?

        if item.save
          new_stock_entry = GeneralInventory.new
          new_stock_entry.lot_number = item.lot_number.upcase
          new_stock_entry.expiration_date = item.expiration_date rescue nil
          new_stock_entry.received_quantity = item.current_quantity
          new_stock_entry.current_quantity = item.current_quantity
          new_stock_entry.rxaui = item.rxaui
          new_stock_entry.gn_identifier= item.pap_identifier
          new_stock_entry.save
          return new_stock_entry
        end
      end
    end
    return false
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
