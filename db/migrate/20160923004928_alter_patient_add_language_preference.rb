class AlterPatientAddLanguagePreference < ActiveRecord::Migration
  def change
    change_table :users do |p|
      p.string :language,:default => "ENG", after: :birthdate
    end
  end
end
