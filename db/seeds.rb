# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "csv"

puts "Loading seed drug thresholds"

CSV.foreach("#{Rails.root}/db/thresholds.csv") do |row|
  concept = Rxnconso.where("RXCUI = ?", row[0].strip).first.RXAUI rescue nil
  next if concept.blank?
  new_drug_threshold = DrugThreshold.where(rxaui: concept, rxcui: row[0].strip).first_or_initialize
  new_drug_threshold.threshold = row[2]
  new_drug_threshold.voided = false
  new_drug_threshold.save
end

puts "load manufacturers"
`rails runner #{Rails.root}/scripts/load_manufacturers.rb`
