class ChangePmapManufacturerType < ActiveRecord::Migration
  change_column :pmap_inventories, :manufacturer, :integer
end
