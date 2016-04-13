class CreatePrescriptions < ActiveRecord::Migration
  def change
    create_table :prescriptions, :primary_key => :rx_id do |t|
      t.integer :patient_id
      t.string :ndc
      t.date :drug_name
      t.integer :quantity
      t.integer :provider_id
      t.boolean :voided
      t.timestamps null: false
    end
  end
end
