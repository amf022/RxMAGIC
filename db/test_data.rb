

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


  def start

    (0..40).each do |i|
      create_general_stocks()
    end

    (0..5).each do |p|
      create_prescriptions()
    end

    (0..10).each do |pap|
      create_pap_stocks()
    end


  end

  def create_general_stocks

    new_stock_entry = GeneralInventory.new
    new_stock_entry.lot_number = (0...5).map { (65 + rand(26)).chr }.join
    new_stock_entry.expiration_date = Time.now.advance(:days => (rand(9000))).strftime('%b-%d-%Y')
    new_stock_entry.received_quantity = rand(2000)
    new_stock_entry.gn_identifier = "GN-#{rand(9999).to_s.rjust(5,'0')}"
    new_stock_entry.date_received = Date.today
    new_stock_entry.rxaui = random_drug
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
    new_prescription.drug_name = Rxnconso.where("RXAUI = ?",new_prescription.rxaui).first.STR
    new_prescription.quantity = ((rand(3) + 1 ) * 30)
    new_prescription.save

  end

  def create_pap_stocks
    patient_id = create_patient

    new_stock_entry = PapInventory.new
    new_stock_entry.patient_id = patient_id
    new_stock_entry.rxaui = random_drug
    new_stock_entry.lot_number = (0...5).map { (65 + rand(26)).chr }.join
    new_stock_entry.expiry_date = Time.now.advance(:days => (rand(9000))).strftime('%b-%d-%Y')
    new_stock_entry.received_quantity = ((rand(3) + 1 ) * 30)
    new_stock_entry.reorder_date = Time.now.advance(:months => (new_stock_entry.received_quantity/30)).strftime('%b-%d-%Y')
    new_stock_entry.date_received = Date.today
    new_stock_entry.pap_identifier = "PAP-#{rand(9999).to_s.rjust(5,'0')}"
    new_stock_entry.save
  end

  def create_provider
    provider = Provider.create({:first_name => random_first_name, :last_name => random_last_name})
    return provider.id
  end

  def random_medicine_name
    drugs = ['Cardura 1 MG Oral Tablet',
	           'Cardura 2 MG Oral Tablet',
             'Zestril 5 MG Oral Tablet',
             "Clozaril 25 MG Oral Tablet",
             "Clozaril 100 MG Oral Tablet",
             "Zofran 4 MG Oral Tablet",
            "Zofran 8 MG Oral Tablet",
            "Naprosyn 250 MG Oral Tablet",
            "Naprosyn 500 MG Oral Tablet",
            "Naprosyn 375 MG Oral Tablet",
            "Topamax 50 MG Oral Tablet",
            "Topamax 100 MG Oral Tablet",
            "Topamax 200 MG Oral Tablet",
            "Tenormin 50 MG Oral Tablet",
            "acyclovir 400 MG Oral Tablet",
            "acyclovir 800 MG Oral Tablet",
            "albuterol 2 MG Oral Tablet",
            "albuterol 4 MG Oral Tablet",
            "dexamethasone 2 MG Oral Tablet",
            "dexamethasone 4 MG Oral Tablet",
            "dexamethasone 6 MG Oral Tablet",
            "diazepam 10 MG Oral Tablet",
            "diazepam 2 MG Oral Tablet",
            "diazepam 5 MG Oral Tablet",
            "fluconazole 100 MG Oral Tablet",
            "fluconazole 150 MG Oral Tablet",
            "fluconazole 200 MG Oral Tablet",
            "fluconazole 50 MG Oral Tablet",
            "ibuprofen 300 MG Oral Tablet",
            "ibuprofen 400 MG Oral Tablet",
            "ibuprofen 600 MG Oral Tablet",
            "ibuprofen 800 MG Oral Tablet",
            "lovastatin 10 MG Oral Tablet",
            "lovastatin 20 MG Oral Tablet",
            "lovastatin 40 MG Oral Tablet",
            "aspirin 486 MG Oral Tablet",
            "aspirin 500 MG Oral Tablet",
            "aspirin 650 MG Oral Tablet",
            "aspirin 80 MG Chewable Tablet",
            "amoxicillin 500 MG Oral Tablet",
            "amoxicillin 875 MG Oral Tablet",
            "isoniazid 100 MG Oral Tablet",
            'Cardura 4 MG Oral Tablet']
    return drugs[rand(drugs.length)]
  end

  def random_drug
    drug = random_medicine_name
    return Rxnconso.where("STR = ?", drug).first.RXAUI
  end

  def random_first_name
    names = ['Harry','Jeremiah','Alfonso','Marion','Douglas','Johnnie','Darlene','Martin','Mario','Lana','Pablo',
             'Estefana','Lewis','Maurine','Jaleesa','Moises','Trinh','Eliza','Felisa','Mignon','Rey','Theo','Ria',
             'Kassandra','Olene','Lahoma','Anjelica','Ehtel','Tanisha','Willette','Gail']

    return names[rand(names.length)]

  end

  def random_last_name
    names = ['Gulley','Conn','Ledbetter','Christiansen','Morrow','Suggs','Burris','Mortensen','Mccffrey','Bethel',
             'Bullard','Fallon','Winkler','Hoff','Dabney','Swain','Osburn','Truit','Hook','Trotter','Douglas','Bennett',
             'Lambert','Hopkins','Blair','Black','Norman','Gomez','Shelton','Martin']

    return names[rand(names.length)]

  end

  def random_state
    states = ['PA','OH']

    return states[rand(states.length)]
  end

  def random_city(state)
    rand_max = $states[state].length
    return $states[state[rand(rand_max)]]
  end

  start
