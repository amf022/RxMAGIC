class AlterPmapTableName < ActiveRecord::Migration
  def self.up
    rename_table :pap_inventories, :pmap_inventories
  end
  def self.down
    rename_table :pap_inventories, :pmap_inventories
  end
end
