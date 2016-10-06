class AddPrescriptionAmountDispensed < ActiveRecord::Migration
  def change
    change_table :prescriptions do |o|
      o.column :amount_dispensed, :integer, :default => 0
    end
  end
  def self.down
  end
end
