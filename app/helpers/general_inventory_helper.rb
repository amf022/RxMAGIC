module GeneralInventoryHelper

  def expired_items(items)
    results = []
    (items || []).each do |item|
      results << {
          "drug_name" => item.drug_name,
          "bottle_id" => item.gn.identifier,
          "lot_number" => item.lot_number,
          "date_received" => item.date_received.strftime("%b %D, %Y"),
          "expiry_date"=> item.expiration_date.strftime("%b %D, %Y"),
          "quantity" => item.current_quantity
      }
    end
    return results
  end
end
