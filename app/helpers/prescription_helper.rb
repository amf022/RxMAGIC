module PrescriptionHelper

  def prescriptions(results)
    # This is a helper method to structure results of the dashboard
    prescriptions = {}
    (results || []).each do |prescription|

      prescriptions[prescription.patient.epic_id] = [] if prescription[prescription.patient.epic_id].blank?
      prescriptions[prescription.patient.epic_id] << {"name" => prescription.patient_name.titleize, "item" => prescription.drug_name.titleize,
                        "quantity" => prescription.quantity, "type" => (prescription.has_pmap ? 'PMAP' : "General"),
                        "prescribed_by" => prescription.prescribed_by}
    end

    return prescriptions
  end
end
