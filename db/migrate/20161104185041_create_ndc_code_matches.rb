class CreateNdcCodeMatches < ActiveRecord::Migration
  def change
    create_table :ndc_code_matches do |t|
      t.string :missing_code
      t.string :rxaui
      t.string :name
      t.timestamps null: false
    end
  end
end
