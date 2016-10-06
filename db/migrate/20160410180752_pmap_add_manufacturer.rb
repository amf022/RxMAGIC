class PmapAddManufacturer < ActiveRecord::Migration
  def self.up
    change_table :pmap_inventories do |o|
      o.column :manufacturer, :string
    end
  end
  def self.down
  end
end
