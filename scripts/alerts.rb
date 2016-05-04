def start

  check_low_pmap_stock
  check_low_general_stock
  check_expiring_pmap_stock
  check_expiring_general_stock
  check_unutilized_pmap_stock
  check_expired_general_items
  check_expired_pmap_items
end

def check_low_pmap_stock

end

def check_low_general_stock
  thresholds = DrugThreshold.where("voided = ?", false)
  items = GeneralInventory.where("voided = ?", false).group(:rxaui).sum(:current_quantity)
  (thresholds || []).each do |threshold|

    if items[threshold.rxaui].blank?
      message = "#{threshold.drug_name} stock below par level"
      create_alert(message, "low general stock")
    else
      if items[threshold.rxaui] <= threshold.threshold
        message = "#{threshold.drug_name} stock below par level"
        create_alert(message, "low general stock")
      end
    end
  end
end

def check_expiring_pmap_stock
  items = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,
                                 0,Date.today.strftime('%Y-%m-%d'),
                                 Date.today.advance(:months => 6).end_of_month.strftime('%Y-%m-%d'))

  (items || []).each do |item|
    message = "#{item.drug_name} with lot number: #{item.lot_number} for #{item.patient_name} expires soon."
    create_alert(message, "expiring item")
  end

end

def check_expiring_general_stock
  items = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                         Date.today.strftime('%Y-%m-%d'),
                         Date.today.advance(:months => 6).end_of_month.strftime('%Y-%m-%d'))

  (items || []).each do |item|
    message = "#{item.drug_name} with lot number: #{item.lot_number} expires soon."
    create_alert(message, "expiring item")
  end

end

def check_unutilized_pmap_stock
  items = PmapInventory.where("voided = ? AND current_quantity > ?", false,0)

  (items || []).each do |item|
    rx = Prescription.where("patient_id = ? AND rxaui =? AND voided = ? AND date_prescribed BETWEEN ? AND ?",
                              item[0],item[1],false,
                            Date.today.advance(:months => -6).beginning_of_month.strftime("%Y-%m-%d 00:00:00"),
                            Date.today.strftime("%Y-%m-%d 23:59:59")).pluck(:rx_id)

    if rx.blank?
      message = "Consider moving #{item.drug_name} for #{item.patient_name} to general stock."
      create_alert(message, "under utilized item")
    end

  end
end

def check_expired_general_items
  items = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ",
                                 false,0, Date.today.strftime('%Y-%m-%d'))

  (items || []).each do |item|
    message = "#{item.drug_name} with lot number: #{item.lot_number} has expired."
    create_alert(message, "expired item")
  end
end

def check_expired_pmap_items
  items = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ",
                                 false,0, Date.today.strftime('%Y-%m-%d'))

  (items || []).each do |item|
    message = "#{item.drug_name} with lot number: #{item.lot_number} for #{item.patient_name} has expired."
    create_alert(message, "expired item")
  end
end

def create_alert(message, type)
  news = News.where("message = ? AND news_type = ? AND resolved = ?",message, type,false).first
  news = News.new if news.blank?
  news.message = message
  news.news_type = type
  news.save
end

start
