class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.text :username
      t.string :user_role
      t.timestamps null: false
    end
  end
end
