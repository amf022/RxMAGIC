class GeneralAddVoidReason < ActiveRecord::Migration
    def self.up
      change_table :general_inventories do |o|
        o.column :void_reason, :string
        o.column :voided_by, :integer
      end
    end
    def self.down
    end
end
