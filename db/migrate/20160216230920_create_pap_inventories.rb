class CreatePapInventories < ActiveRecord::Migration
  def change
    create_table :pap_inventories,  :primary_key => :pap_inventory_id do |t|
    t.string :rxaui
    t.string :lot_number
    t.string :pap_identifier
    t.integer :patient_id
    t.date :expiry_date
    t.integer :received_quantity, :default => 0
    t.integer :current_quantity, :default => 0
    t.date :reorder_date
    t.date :date_received
    t.boolean :voided, :default => false
    t.string :void_reason
    t.timestamps null: false
    end
  end
end
