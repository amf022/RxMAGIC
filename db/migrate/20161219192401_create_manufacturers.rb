class CreateManufacturers < ActiveRecord::Migration
  def change
    create_table :manufacturers, :primary_key => :mfn_id do |t|
      t.string :name
      t.boolean :has_pmap, :default => false
      t.timestamps null: false
    end
  end
end
