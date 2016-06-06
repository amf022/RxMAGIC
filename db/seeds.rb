# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

puts "Loading seed drug thresholds"

thresholds = {"995253"=> 114,
              "995278"=> 96,
              "200371"=> 287,
              "309314"=> 98,
              "310385"=> 245,
              "313989"=> 165,
              "856373"=> 141,
              "993518"=> 253,
              "856834"=> 177,
              "314076"=> 3320,
              "314077"=> 404,
              "197884"=> 378,
              "979492"=> 174,
              "979480"=> 234,
              "866924"=> 430,
              "866514"=> 421,
              "866511"=> 141
}

(thresholds.keys || []).each do |item|
  concept = Rxnconso.where("RXCUI = ? AND TTY = 'PSN'", item).first.RXAUI rescue nil
  next if concept.blank?
  new_drug_threshold = DrugThreshold.where(rxaui: concept).first_or_initialize
  new_drug_threshold.threshold = thresholds[item]
  new_drug_threshold.voided = false
  new_drug_threshold.save
end