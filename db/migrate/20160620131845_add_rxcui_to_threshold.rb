class AddRxcuiToThreshold < ActiveRecord::Migration
  def change
    change_table :drug_thresholds do |o|
      o.string :rxcui, null: false
    end
  end
end
