class AddManufacturerToGnInventory < ActiveRecord::Migration
  def change
    change_table :general_inventories do |p|
      p.integer :mfn_id, after: :lot_number
    end
  end
end
