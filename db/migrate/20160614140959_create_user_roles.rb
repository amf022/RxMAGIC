class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.text :first_name
      t.text :last_name
      t.text :username
      t.text :user_role

      t.timestamps null: false
    end
  end
end
