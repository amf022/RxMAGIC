module PmapInventoryHelper
  def reorders(inventory)
    results = []
    (inventory || []).each do |item|
      results << {"patient_name" => item.patient_name,
                  "patient_gender" => item.patient.patient_gender,
                  "patient_birthdate" => item.patient.birthdate_formatted,
                  "drug" => item.drug_name,
                  "reorder_date" => item.reorder_date.to_date.strftime('%b %d, %Y'),
                  "manufacturer" => (item.manufacturer.blank? ? "Unknown" : item.manufacturer),
                  "id" => item.id}
    end

    return results
  end

  def expired(items)
    results = []
    (items || []).each do |item|
      results << {
          "patient_name" => item.patient_name,
          "drug_name" => item.drug_name,
          "bottle_id" => Misc.dash_formatter(item.bottle_id),
          "date_received" => item.date_received.strftime("%b %d, %Y"),
          "expiry_date"=> item.expiration_date.strftime("%b %d, %Y"),
          "quantity" => item.current_quantity
      }
    end
    return results
  end

  def underutilized(inventory, items,patients)
    results = []
    (@inventory || []).each do |item|
      results << {'item' => (items[item[0]].downcase.titleize rescue ""),
      'item_identifier'=> Misc.dash_formatter(item[5]),
      'patient'=> patients[item[1]].titleize,
      'lot_number'=> Misc.dash_formatter(item[2]),
      'current_quantity'=> item[3],
      'expiration_date'=> item[4].strftime('%b-%Y')
      }
    end

  end
end
