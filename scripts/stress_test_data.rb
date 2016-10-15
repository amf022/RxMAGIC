

#This script is to create test data for the RxMAGIC application

$states = {"PA" => ['Aliquippa','Allentown','Altoona','Arnold','Beaver Falls','Bethlehem','Bradford','Butler',
                    'Carbondale','Chester','Clairton','Coatesville','Connellsville','Corry','DuBois','Duquesne',
                    'Easton','Erie','Farrell','Franklin','Greensburg','Harrisburg','Hazleton','Hermitage','Jeannette',
                    'Johnstown','Lancaster','Latrobe','Lebanon','Lock Haven','Lower Burrell','McKeesport','Meadville',
                    'Monessen','Monongahela','Nanticoke','New Castle','New Kensington','Oil City','Parker',
                    'Philadelphia','Pittsburgh','Pittston','Pottsville','Reading','St.Marys','Scranton','Shamokin','Sharon',
                    'Sunbury','Titusville','Uniontown','Warren','Washington','Wilkes-Barre','Williamsport','York'],
           "OH" => ['Lima','Delphos','Ashland','Ashtabula','Conneaut','Geneva','Athens','Nelsonville','St. Marys','Wapakoneta',
                    'Martins Ferry','St.Clairsville','Fairfield','Hamilton','Middletown','Oxford','Trenton','Monroe',
                    'Urbana','New Carlisle','Springfield','Milford','Wilmington','East Liverpool','Salem','Columbiana',
                    'Coshocton','Bucyrus','Galion','Bay Village','Beachwood','Bedford','Bedford Heights','Berea',
                    'Brecksville','Broadview Heights','Brooklyn','Brook Park','Cleveland','Cleveland Heights',
                    'East Cleveland','Euclid','Fairview Park','Garfield Heights','Highland Heights','Independence',
                    'Lakewood','Lyndhurst','Maple Heights','Mayfield Heights','Middleburg Heights','North Olmsted',
                    'North Royalton','Olmsted Falls','Parma','Parma Heights']}


$manufacturers = JSON.parse(File.open("#{Rails.root}/app/assets/data/manufacturers.json").read)


def start
=begin
  puts "Creating 5000 patients"
  (1..5000).each do |i|
    create_patient()
  end
=end
  puts "Creating 1500 general inventory entries"
  (1..1500).each do |p|
    create_general_stocks()
  end

  puts "Creating 500 PMAP stock items "
  (1..500).each do |pap|
    create_pap_stocks()
  end

  puts "Creating 15000 prescriptions records"
  (1..15000).each do |pap|
    create_prescriptions
  end

  puts "Creating dispensations"
  create_dispensations
end

def create_general_stocks

  new_stock_entry = GeneralInventory.new
  new_stock_entry.lot_number = (0...5).map { (65 + rand(26)).chr }.join
  new_stock_entry.expiration_date = Time.now.advance(:months => (rand(36))).strftime('%b-%d-%Y')
  new_stock_entry.received_quantity = rand(2000)
  new_stock_entry.current_quantity = new_stock_entry.received_quantity
  new_stock_entry.date_received = Time.now.advance(:days => -(rand(1050))).strftime('%b-%d-%Y')
  new_stock_entry.rxaui = random_drug
  new_stock_entry.save
end

def create_patient
  new_patient = Patient.new
  new_patient.epic_id = (0...6).map { (65 + rand(26)).chr }.join
  new_patient.first_name = random_first_name
  new_patient.last_name = random_last_name
  new_patient.gender = (rand(2) == 0 ? "F" : "M")
  new_patient.birthdate = Time.now.advance(:days => (rand(30000)*-1)).strftime('%b-%d-%Y')
  new_patient.state = random_state
  new_patient.city = random_city(new_patient.state)
  new_patient.zip = rand(99999)
  new_patient.save
  return new_patient.id
end

def create_prescriptions
  patient_id = rand(5000)

  new_prescription = Prescription.new
  new_prescription.provider_id = create_provider
  new_prescription.patient_id = patient_id
  new_prescription.rxaui = random_drug
  new_prescription.directions = random_directions
  new_prescription.date_prescribed = Time.now.advance(:days => (rand(365)*-1)).strftime('%b-%d-%Y')
  new_prescription.quantity = ((rand(3) + 1 ) * 30)
  new_prescription.save

end

def create_pmap_prescriptions()
  pap_items = PmapInventory.all

  rand_inventory = pap_items[rand(pap_items.length)]

  new_prescription = Prescription.new
  new_prescription.provider_id = create_provider
  new_prescription.patient_id = rand_inventory.patient_id
  new_prescription.rxaui = rand_inventory.rxaui
  new_prescription.directions = random_directions
  new_prescription.date_prescribed = Time.now.advance(:days => (rand(5)*-1)).strftime('%b-%d-%Y')
  new_prescription.quantity = ((rand(3) + 1 ) * 30)
  new_prescription.save

end

def create_pap_stocks
  patient_id = rand(5000)

  new_stock_entry = PmapInventory.new
  new_stock_entry.patient_id = patient_id
  new_stock_entry.rxaui = random_drug
  new_stock_entry.lot_number = (0...5).map { (65 + rand(26)).chr }.join
  new_stock_entry.expiration_date = Time.now.advance(:months => (rand(36))).strftime('%b-%d-%Y')
  new_stock_entry.received_quantity = ((rand(3) + 1 ) * 30)
  new_stock_entry.current_quantity = new_stock_entry.received_quantity
  new_stock_entry.reorder_date = Time.now.advance(:months => (new_stock_entry.received_quantity/30)).strftime('%b-%d-%Y')
  new_stock_entry.date_received = Time.now.advance(:days => -(rand(1050))).strftime('%b-%d-%Y')
  new_stock_entry.manufacturer = random_manufacturer
  new_stock_entry.save

end

def create_provider
  provider = Provider.create({:first_name => random_first_name, :last_name => random_last_name})
  return provider.id
end

def create_dispensations

  prescriptions = Prescription.all

  (prescriptions || []).each do |prescription|
    puts "Prescription #{prescription.rx_id}"
    if prescription.has_pmap
      options = PmapInventory.where("current_quantity > 0 AND voided = ? AND rxaui = ? AND patient_id = ?",
                                    false, prescription.rxaui, prescription.patient_id)
    else
      options = GeneralInventory.where("current_quantity > 0 AND voided = ? AND rxaui = ?", false, prescription.rxaui)
    end

    next if options.blank?

    while (prescription.amount_dispensed < prescription.quantity)
      (options || []).each do |option|
        if option.current_quantity >= prescription.quantity
          amount_to_dispense = prescription.quantity
        else
          amount_to_dispense = option.current_quantity
        end

        Dispensation.transaction do

          option.current_quantity -= amount_to_dispense.to_i

          if option.save

            prescription.amount_dispensed += amount_to_dispense.to_i
            prescription.save

            dispensation = Dispensation.create({:rx_id => prescription.id, :inventory_id => option.bottle_id,
                                                :patient_id => prescription.patient_id, :quantity => amount_to_dispense,
                                                :dispensation_date => prescription.date_prescribed.advance(:minutes => rand(60))})
          end
        end
        break if prescription.amount_dispensed >= prescription.quantity
      end
      break
    end
  end
end

def random_medicine_name
  drugs = ["Anadrol-50 50 MG Oral Tablet","Lufyllin 400 MG Oral Tablet","MAXZIDE 75 MG / 50 MG Oral Tablet",
           "MAXZIDE-25 MG 37.5 MG / 25 MG Oral Tablet","Mykrox 500 MCG Oral Tablet","Sedapap 50 MG / 650 MG Oral Tablet",
           "Trimox 500 MG Oral Capsule","primidone 250 MG Oral Tablet","Robinul Forte 2 MG Oral Tablet",
           "levamisole HCl 50 MG Oral Tablet","Mycobutin 150 MG Oral Capsule","Lescol 20 MG Oral Capsule",
           "Lescol 40 MG Oral Capsule","lamoTRIgine 100 MG Disintegrating Oral Tablet",
           "sodium bicarbonate 300 MG Oral Tablet","Cantil 25 MG Oral Tablet","Pro-Banthine 15 MG Oral Tablet",
           "Tagamet HB 200 MG Oral Tablet","Pepcid AC 20 MG Oral Tablet","Pepcid 40 MG Oral Tablet",
           "AXID 150 MG Oral Capsule","Cytotec 200 MCG Oral Tablet","Asacol 400 MG Delayed Release Oral Tablet",
           "LANOXIN 62.5 MCG Oral Tablet","bumetanide 5 MG Oral Tablet","Cardura 1 MG Oral Tablet",
           "Cardura 2 MG Oral Tablet","Cardura 4 MG Oral Tablet","Zestril 2.5 MG Oral Tablet, Once-Daily",
           "Zestril 5 MG Oral Tablet","Zestril 10 MG Oral Tablet, Once-Daily","Zestril 20 MG Oral Tablet, Once-Daily",
           "Altace 2.5 MG Oral Capsule","Altace 5 MG Oral Capsule","Plendil 5 MG 24HR Extended Release Oral Tablet",
           "Plendil 10 MG 24HR Extended Release Oral Tablet","tranexamic acid 500 MG Oral Tablet",
           "Zocor 10 MG Oral Tablet","Zocor 20 MG Oral Tablet","Valium 2 MG Oral Tablet","Valium 5 MG Oral Tablet",
           "Valium 10 MG Oral Tablet","bromazepam 1.5 MG Oral Tablet","Ativan 1 MG Oral Tablet",
           "periciazine 2.5 MG Oral Tablet","periciazine 10 MG Oral Tablet","pimozide 4 MG Oral Tablet",
           "Clozaril 25 MG Oral Tablet","Clozaril 100 MG Oral Tablet","RisperDAL 1 MG Oral Tablet",
           "RisperDAL 2 MG Oral Tablet","RisperDAL 3 MG Oral Tablet","RisperDAL 4 MG Oral Tablet",
           "Nardil 15 MG Oral Tablet","isocarboxazid 10 MG Oral Tablet","Parnate 10 MG Oral Tablet",
           "PROzac 20 MG Oral Capsule","betahistine hydrochloride 8 MG Oral Tablet","Cesamet 1 MG Oral Capsule",
           "ondansetron 4 MG Disintegrating Oral Tablet","Zofran 4 MG Oral Tablet","Zofran 8 MG Oral Tablet",
           "LaMICtal 100 MG Oral Tablet","LaMICtal 25 MG Oral Tablet","Neurontin 100 MG Oral Capsule",
           "Neurontin 300 MG Oral Capsule","Neurontin 400 MG Oral Capsule","Parlodel 5 MG Oral Capsule",
           "Terramycin 250 MG Oral Capsule","LamISIL 250 MG Oral Tablet","dapsone 100 MG / pyrimethamine 12.5 MG Oral Tablet",
           "mebendazole 100 MG Chewable Tablet","Parlodel 2.5 MG Oral Tablet","Metopirone 250 MG Oral Capsule",
           "levonorgestrel 30 MCG Oral Tablet","carbachol 2 MG Oral Tablet","Myleran 2 MG Oral Tablet",
           "LEUKERAN Tablets 2 MG Oral Tablet","ALKERAN 2 MG Oral Tablet","methotrexate 2.5 MG Oral Tablet",
           "methotrexate 10 MG Oral Tablet","TABLOID 40 MG Oral Tablet","Hydrea 500 MG Oral Capsule",
           "IMURAN 50 MG Oral Tablet","Nolvadex 10 MG Oral Tablet","vitamin B 12 50 MCG Oral Tablet",
           "Dolobid 500 MG Oral Tablet","Naprosyn 250 MG Oral Tablet","Naprosyn 500 MG Oral Tablet",
           "Naprosyn 375 MG Oral Tablet","Feldene 10 MG Oral Capsule","Feldene 20 MG Oral Capsule",
           "tenoxicam 20 MG Oral Tablet","Daranide 50 MG Oral Tablet","Surmontil 50 MG Oral Capsule",
           "Cedax 400 MG Oral Capsule","Prograf 1 MG Oral Capsule","Prograf 5 MG Oral Capsule",
           "VALTREX 500 MG Oral Tablet","LaMICtal 200 MG Oral Tablet"]
  return drugs[rand(drugs.length)]
end

def random_drug
	rxaui = nil
	
	while rxaui.blank?
	  drug = random_medicine_name		
	  rxaui = Rxnconso.where("STR = ?", drug).first.RXAUI rescue nil
	end

  return rxaui
end

def random_first_name
  names = ['Harry','Jeremiah','Alfonso','Marion','Douglas','Johnnie','Darlene','Martin','Mario','Lana','Pablo',
           'Estefana','Lewis','Maurine','Jaleesa','Moises','Trinh','Eliza','Felisa','Mignon','Rey','Theo','Ria',
           'Kassandra','Olene','Lahoma','Anjelica','Ehtel','Tanisha','Willette','Gail',"Denna","Mellissa","Bess",
           "Abigail","Alexandra","Alison","Amanda","Amelia","Amy","Andrea","Angela","Anna","Anne","Audrey","Ava",
           "Bella","Bernadette","Carol","Caroline","Carolyn","Chloe","Claire","Deirdre","Diana","Diane","Donna",
           "Dorothy","Elizabeth","Ella","Emily","Emma","Faith","Felicity","","Megan","Melanie","Michelle","Molly",
           "Natalie","Nicola","Olivia","Penelope","Pippa","Rachel","Rebecca","Rose","Ruth","Sally","Samantha","Sarah",
           "Sonia","Sophie","Stephanie","Sue","Theresa","Tracey","Una","Vanessa","Victoria","Virginia","Wanda","Adam",
           "Adrian","Alan","Alexander","Andrew","Anthony","Austin","Benjamin","Blake","Boris","Brandon","Brian",
           "Cameron","Carl","Charles","Christian","Christopher","Colin","Connor","Dan","David","Dominic","Dylan",
           "Edward","Eric","Evan","Frank","Gavin","Gordon","Harry", "Denise","Berneice","Arlie","Gaynelle",
           "Fidelia","Vanetta","Julie","Mary","Sherie","Keisha","Piedad", "Dina","Danna"]

  return names[rand(names.length)]

end

def random_last_name
  names = ["Ball","Bell","Berry","Black","Blake","Bond","Bower","Brown","Buckland","Burgess","Butler","Cameron",
           "Campbell","Carr","Chapman","Churchill","Clark","Clarkson","Coleman","Cornish","Davidson","Davies",
           "Dickens","Dowd","Duncan","Dyer","Edmunds","Ellison","Ferguson","Fisher","Forsyth","Fraser","Gibson",
           "Gill","Glover","Graham","Grant","Gray","Greene","Hamilton","Hardacre","Harris","Hart","Hemmings",
           "Henderson","Hill","Hodges","Howard","Hudson","Hughes","Hunter","Ince","Jackson","James","Johnston","Jones",
           "Kelly","Kerr","King","Knox","Lambert","Langdon","Lawrence","Lee","Lewis","Lyman","MacDonald","Mackay",
           "Mackenzie","MacLeod","Manning","Marshall","Martin","Mathis","May","McDonald","McLean","McGrath",'Gulley',
           'Conn','Ledbetter','Christiansen','Morrow','Suggs','Burris','Mortensen','Mccffrey','Bethel',
           'Bullard','Fallon','Winkler','Hoff','Dabney','Swain','Osburn','Truit','Hook','Trotter','Douglas','Bennett',
           "WESTBAY","WEPPLER","WAMBOLDT","WALDROOP","VONDRASEK","VLAHAKIS","VINSANT","VANO","VANDERWEELE","TUFARO",
           "TUCKERMAN","TRUEHEART","TRETTIN","STAVISH","STARIN","SOOKRAM","SONNENFEL",
           'Lambert','Hopkins','Blair','Black','Norman','Gomez','Shelton','Martin']

  return names[rand(names.length)]

end

def random_state
  states = ['PA','OH']

  return states[rand(states.length)]
end

def random_city(state)
  rand_max = $states[state].length
  return $states[state][rand(rand_max)]
end

def random_directions
  directions = ['Take 2 tablets by mouth daily','Take 3 tablets by mouth daily','Take 1 tablet by mouth 3 times a day',
                'Take 1 tablet by mouth daily', 'Take 2 tablets by mouth 3 times a day']

  return directions[rand(directions.length)]
end

def random_manufacturer
  return $manufacturers[rand($manufacturers.length)]
end
start
