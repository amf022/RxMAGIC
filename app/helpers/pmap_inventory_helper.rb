module PmapInventoryHelper
  def reorders(inventory)
    results = []
    (inventory || []).each do |item|
      results << {"patient_name" => item.patient_name,
                  "patient_gender" => item.patient.patient_gender,
                  "patient_birthdate" => item.patient.birthdate_formatted,
                  "drug" => item.drug_name,
                  "reorder_date" => item.reorder_date.to_date.strftime('%b-%d-%Y'),
                  "manufacturer" => (item.manufacturer.blank? ? "Unknown" : item.manufacturer),
                  "id" => item.id}
    end

    return results
  end
end
