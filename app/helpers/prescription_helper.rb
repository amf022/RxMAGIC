module PrescriptionHelper

  def prescriptions(results)
    # This is a helper method to structure results of the dashboard
    prescriptions = []
    (results || []).each do |prescription|
      prescriptions << {"name" => prescription.patient_name, "item" => prescription.drug_name,
                        "quantity" => prescription.quantity, "type" => (prescription.has_pmap ? 'PMAP' : "General")}
    end

    return prescriptions
  end
end
