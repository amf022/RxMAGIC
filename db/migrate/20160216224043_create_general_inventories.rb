class CreateGeneralInventories < ActiveRecord::Migration
  def change
    create_table :general_inventories, :primary_key => :gn_inventory_id do |t|
      t.integer :rxaui
      t.string :gn_identifier
      t.string :lot_number
      t.date :expiration_date
      t.date :date_received
      t.integer :received_quantity, :default => 0
      t.integer :current_quantity, :default => 0
      t.timestamps null: false
    end
  end
end
