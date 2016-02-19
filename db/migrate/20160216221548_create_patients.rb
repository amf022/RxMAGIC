class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients, :primary_key => :patient_id do |t|
      t.string :epic_id
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.date :birthdate
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.boolean :voided
      t.timestamps null: false
    end
  end
end
