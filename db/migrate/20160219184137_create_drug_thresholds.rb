class CreateDrugThresholds < ActiveRecord::Migration
  def change
    create_table :drug_thresholds, :primary_key => :threshold_id do |t|
      t.string :rxaui
      t.integer :threshold
      t.timestamps null: false
    end
  end
end
