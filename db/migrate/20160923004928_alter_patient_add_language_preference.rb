class AlterPatientAddLanguagePreference < ActiveRecord::Migration
  def change
    change_table :patients do |p|
      p.string :language,:default => "ENG", after: :birthdate
    end
  end
end
