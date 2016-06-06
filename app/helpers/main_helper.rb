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
end
