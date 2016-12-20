CSV.foreach("#{Rails.root}/db/manufacturers.csv",{:headers=>:first_row}) do |row|
  company = Manufacturer.where(name: row[0].strip).first_or_initialize
  company.has_pmap = row[1].strip rescue false
  company.save
end