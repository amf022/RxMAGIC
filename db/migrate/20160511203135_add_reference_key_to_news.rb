class AddReferenceKeyToNews < ActiveRecord::Migration
  def change
    change_table :news do |o|
      o.column :refers_to, :string
    end
  end
  def self.down
  end
end
