module GeneralInventoryHelper
  def expired_items(items)
    results = []
    (items || []).each do |item|
      results << {
          "drug_name" => item.drug_name,
          "bottle_id" => Misc.dash_formatter(item.gn_identifier),
          "lot_number" => Misc.dash_formatter(item.lot_number),
          "date_received" => item.date_received.strftime("%b %d, %Y"),
          "expiry_date"=> item.expiration_date.strftime("%b %d, %Y"),
          "quantity" => item.current_quantity
      }
    end
    return results
  end

  def understocked_items(items)
    results = []
    (items || []).each do |item|
      results << {
          "drug_name" => item.drug_name,
          "threshold" => item.lot_number,
          "available" => item.date_received.strftime("%b %d, %Y")
      }
    end
    return results
  end
end
