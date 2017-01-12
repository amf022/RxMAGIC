

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

    puts "Creating 20 General Inventory Stock Items"
    (1..40).each do |i|
      create_general_stocks()
    end

    puts "Creating 15 general inventory prescriptions"
    (1..10).each do |p|
      create_prescriptions()
    end

    puts "Creating 15 PMAP stock items"
    (1..15).each do |pap|
      create_pap_stocks()
    end

    puts "Creating 15 PMAP prescriptions"
    (1..10).each do |pap|
      create_pmap_prescriptions()
    end
  end

  def create_general_stocks

    offset = rand(Manufacturer.count)
    new_stock_entry = GeneralInventory.new
    new_stock_entry.lot_number = (0...5).map { (65 + rand(26)).chr }.join
    new_stock_entry.expiration_date = Time.now.advance(:days => (rand(365))).strftime('%b-%d-%Y')
    new_stock_entry.received_quantity = rand(2000)
    new_stock_entry.current_quantity = new_stock_entry.received_quantity
    new_stock_entry.date_received = Time.now.advance(:days => -(rand(365))).strftime('%b-%d-%Y')
    new_stock_entry.rxaui = random_drug
    new_stock_entry.mfn_id = Manufacturer.offset(offset).first.id
    new_stock_entry.save
  end

  def create_patient
    new_patient = Patient.new
    new_patient.epic_id = (0...6).map { (65 + rand(26)).chr }.join
    new_patient.first_name = random_first_name
    new_patient.last_name = random_last_name
    new_patient.gender = (rand(2) == 0 ? "F" : "M")
    new_patient.birthdate = Time.now.advance(:weeks => (rand(300)*-1)).strftime('%b-%d-%Y')
    new_patient.state = random_state
    new_patient.city = random_city(new_patient.state)
    new_patient.zip = rand(99999)
    new_patient.save
    return new_patient.id
  end

  def create_prescriptions
    patient_id = create_patient

    new_prescription = Prescription.new
    new_prescription.provider_id = create_provider
    new_prescription.patient_id = patient_id
    new_prescription.rxaui = random_drug
    new_prescription.directions = random_directions
    new_prescription.date_prescribed = Time.now.advance(:days => (rand(5)*-1)).strftime('%b-%d-%Y')
    new_prescription.quantity = ((rand(3) + 1 ) * 30)
    new_prescription.save

    news = News.new
    news.message = "#{new_prescription.quantity} of #{new_prescription.drug_name} for #{new_prescription.patient_name}"
    news.news_type = "new prescription"
    news.refers_to = new_prescription.id
    news.save

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

    news = News.new
    news.message = "#{new_prescription.quantity} of #{new_prescription.drug_name} for #{new_prescription.patient_name}"
    news.news_type = "new prescription"
    news.refers_to = new_prescription.id
    news.save
  end

  def create_pap_stocks
    patient_id = create_patient

    new_stock_entry = PmapInventory.new
    new_stock_entry.patient_id = patient_id
    new_stock_entry.rxaui = random_drug
    new_stock_entry.lot_number = (0...5).map { (65 + rand(26)).chr }.join
    new_stock_entry.expiration_date = Time.now.advance(:days => (rand(365))).strftime('%b-%d-%Y')
    new_stock_entry.received_quantity = ((rand(3) + 1 ) * 30)
    new_stock_entry.current_quantity = new_stock_entry.received_quantity
    new_stock_entry.reorder_date = Time.now.advance(:months => (new_stock_entry.received_quantity/30)).strftime('%b-%d-%Y')
    new_stock_entry.date_received = Time.now.advance(:days => -(rand(365))).strftime('%b-%d-%Y')
    new_stock_entry.manufacturer = random_manufacturer
    new_stock_entry.save

  end

  def create_provider
    provider = Provider.create({:first_name => random_first_name, :last_name => random_last_name})
    return provider.id
  end

  def random_medicine_name
    drugs = ["Cardura 1 MG Oral Tablet","Cardura 2 MG Oral Tablet","Cardura 4 MG Oral Tablet","Zestril 5 MG Oral Tablet","Clozaril 25 MG Oral Tablet","Clozaril 100 MG Oral Tablet","Zofran 4 MG Oral Tablet","Zofran 8 MG Oral Tablet","Naprosyn 250 MG Oral Tablet","Naprosyn 500 MG Oral Tablet","Naprosyn 375 MG Oral Tablet","Topamax 50 MG Oral Tablet","Topamax 100 MG Oral Tablet","Topamax 200 MG Oral Tablet","Tenormin 50 MG Oral Tablet","acyclovir 400 MG Oral Tablet","acyclovir 800 MG Oral Tablet","albuterol 2 MG Oral Tablet","albuterol 4 MG Oral Tablet","dexamethasone 2 MG Oral Tablet","dexamethasone 4 MG Oral Tablet","dexamethasone 6 MG Oral Tablet","diazepam 10 MG Oral Tablet","diazepam 2 MG Oral Tablet","diazepam 5 MG Oral Tablet","fluconazole 100 MG Oral Tablet","fluconazole 150 MG Oral Tablet","fluconazole 200 MG Oral Tablet","fluconazole 50 MG Oral Tablet","ibuprofen 400 MG Oral Tablet","ibuprofen 600 MG Oral Tablet","ibuprofen 800 MG Oral Tablet","lovastatin 10 MG Oral Tablet","lovastatin 20 MG Oral Tablet","lovastatin 40 MG Oral Tablet","aspirin 500 MG Oral Tablet","aspirin 650 MG Oral Tablet","amoxicillin 500 MG Oral Tablet","amoxicillin 875 MG Oral Tablet","isoniazid 100 MG Oral Tablet"]
    return drugs[rand(drugs.length)]
  end

  def random_drug
    drug = random_medicine_name

    return Rxnconso.where("STR = ?", drug).first.RXAUI
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
