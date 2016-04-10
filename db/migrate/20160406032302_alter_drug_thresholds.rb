class AlterDrugThresholds < ActiveRecord::Migration
  def change
    change_table :drug_thresholds do |o|
      o.column :voided, :boolean, :default => false
    end
  end
end
