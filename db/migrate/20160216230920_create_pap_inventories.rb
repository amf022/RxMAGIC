class CreatePapInventories < ActiveRecord::Migration
  def change
    create_table :pap_inventories,  :primary_key => :pap_inventory_id do |t|
    t.string :rxcui
    t.string :lot_number
    t.integer :patient_id
    t.date :expiry_date
    t.integer :received_quantity, :default => 0
    t.integer :current_quantity, :default => 0
    t.date :reorder_date
    t.date :date_received
    t.boolean :voided
    t.string :void_reason
    t.timestamps null: false
    end
  end
end
