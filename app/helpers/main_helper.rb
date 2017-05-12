module MainHelper

  def activities(dispensations)
    results = {}
    (dispensations || []).each do |dispensation|
      results[dispensation.patient_id] = {} if results[dispensation.patient_id].blank?
      results[dispensation.patient_id][dispensation.drug_name] = {} if results[dispensation.patient_id][dispensation.drug_name].blank?
      results[dispensation.patient_id][dispensation.drug_name]["directions"] = dispensation.prescription.directions
      results[dispensation.patient_id][dispensation.drug_name]["patient_name"] = dispensation.patient.fullname
      results[dispensation.patient_id][dispensation.drug_name]["prescription"] = dispensation.rx_id
      results[dispensation.patient_id][dispensation.drug_name]["source"] = [] if results[dispensation.patient_id][dispensation.drug_name]["source"].blank?
      results[dispensation.patient_id][dispensation.drug_name]["source"] << Misc.source_of_meds(dispensation.patient_id,
                                                                                               dispensation.inventory_id)

      sources = results[dispensation.patient_id][dispensation.drug_name]["source"]
      reorder = ((sources.include?('Borrowed') || sources.include?('PMAP')) ? Misc.reorder_meds(dispensation.patient_id,dispensation.prescription.rxaui) : false )
      results[dispensation.patient_id][dispensation.drug_name]["reorder"] = reorder

      temp = results[dispensation.patient_id][dispensation.drug_name]["quantity"]
      results[dispensation.patient_id][dispensation.drug_name]["quantity"] = (temp.blank? ? dispensation.quantity : (temp + dispensation.quantity))
    end
    return results
  end

  def compile_report(prescriptions,inventory,later_dispensations)
    records = {}

    (prescriptions || []).each do |prescription|
      records[prescription.rxaui] = {"drug_name" => prescription.drug_name, "stock" => 0, "rx_num" => 0,
                                     "amount_prescribed" => 0, "amount_dispensed" => 0} if records[prescription.rxaui].blank?

      records[prescription.rxaui]["rx_num"] = prescription.rx_id
      records[prescription.rxaui]["amount_dispensed"] = number_with_delimiter(prescription.amount_dispensed)
      records[prescription.rxaui]["amount_prescribed"] = number_with_delimiter(prescription.quantity)
    end

    (inventory || []).each do |item|
      records[item.rxaui] = {"drug_name" => item.drug_name, "stock" => 0, "rx_num" => 0,
                           "amount_prescribed" => 0, "amount_dispensed" => 0} if records[item.rxaui].blank?

      records[item.rxaui]["stock"] += item.current_quantity
    end

    (later_dispensations || []).each do |item|
      records[item.rxaui] = {"drug_name" => Rxnconso.find(item.rxaui).STR, "stock" => 0, "rx_num" => 0,
                             "amount_prescribed" => 0, "amount_dispensed" => 0} if records[item.rxaui].blank?

      records[item.rxaui]["stock"] += item.quantity
    end

    return records
  end

end
