class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers, :primary_key => :provider_id do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps null: false
    end
  end
end
