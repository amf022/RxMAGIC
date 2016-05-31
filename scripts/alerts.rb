def start

  check_low_pmap_stock
  check_low_general_stock
  #check_expiring_pmap_stock
  #check_expiring_general_stock
  check_unutilized_pmap_stock
  check_expired_general_items
  check_expired_pmap_items
end

def check_low_pmap_stock

  # This code block is meant to get all low pmap meds

  main_items = PmapInventory.find_by_sql("SELECT patient_id,rxaui, sum(received_quantity) as received_quantity,
                                          sum(current_quantity) as current_quantity from pmap_inventories pi where pi.voided = 0 and
                                          pi.date_received = (SELECT MAX(date_received) FROM pmap_inventories pm
                                          WHERE pm.patient_id = pi.patient_id AND pm.rxaui = pi.rxaui AND pm.voided = 0)
                                          group by patient_id, rxaui")

  (main_items || []).each do |main_item|
    if (main_item.current_quantity.to_f/main_item.received_quantity.to_f) < 0.50
      message = "#{main_item.patient_name} has #{main_item.current_quantity} of #{main_item.drug_name} remaining. Consider reordering."
      create_alert(message, "low pmap stock", "#{main_item.patient_id}-#{main_item.rxaui}")
    end
  end
end

def check_low_general_stock

  #this code block gets all items that have fewer than the permissible amounts available

  thresholds = DrugThreshold.where("voided = ?", false)
  items = GeneralInventory.where("voided = ?", false).group(:rxaui).sum(:current_quantity)
  (thresholds || []).each do |threshold|

    if items[threshold.rxaui].blank?
      message = "#{threshold.drug_name} stock below par level"
      create_alert(message, "low general stock", threshold.rxaui)
    else
      if items[threshold.rxaui] <= threshold.threshold
        message = "#{threshold.drug_name} stock below par level"
        create_alert(message, "low general stock", threshold.rxaui)
      end
    end
  end
end

def check_expiring_pmap_stock

  #this code block gets all pmap items that are expiring in the next 6 months

  items = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,
                                 0,Date.today.strftime('%Y-%m-%d'),
                                 Date.today.advance(:months => 6).end_of_month.strftime('%Y-%m-%d'))

  (items || []).each do |item|
    message = "#{item.drug_name} with lot number: #{item.lot_number} for #{item.patient_name} expires soon."
    create_alert(message, "expiring item", item.pap_identifier)
  end

end

def check_expiring_general_stock

  #this code block gets all general items that are expiring in the next 6 months

  items = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date  BETWEEN ? AND ?",false,0,
                         Date.today.strftime('%Y-%m-%d'),
                         Date.today.advance(:months => 2).end_of_month.strftime('%Y-%m-%d'))

  (items || []).each do |item|
    message = "#{item.drug_name} with lot number: #{item.lot_number} expires soon."
    create_alert(message, "expiring item", item.gn_identifier)
  end

end

def check_unutilized_pmap_stock

  #this code block gets all pmap items that have not been used in the last 6 months

  items = PmapInventory.where("voided = ? AND current_quantity > ?", false,0)

  (items || []).each do |item|
    rx = Prescription.where("patient_id = ? AND rxaui =? AND voided = ? AND date_prescribed BETWEEN ? AND ?",
                              item[0],item[1],false,
                            Date.today.advance(:months => -6).beginning_of_month.strftime("%Y-%m-%d 00:00:00"),
                            Date.today.strftime("%Y-%m-%d 23:59:59")).pluck(:rx_id)

    if rx.blank?
      message = "Consider moving #{item.drug_name} for #{item.patient_name} to general stock."
      create_alert(message, "under utilized item", item.pap_identifier)
    end

  end
end

def check_expired_general_items

  #this code block gets all general items that are expired

  items = GeneralInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ",
                                 false,0, Date.today.strftime('%Y-%m-%d'))

  (items || []).each do |item|
    message = "#{item.drug_name} with lot number: #{item.lot_number} has expired."
    create_alert(message, "expired item", item.gn_identifier)
  end
end

def check_expired_pmap_items

  #this code block gets all pmap items that are expired

  items = PmapInventory.where("voided = ? AND current_quantity > ? AND expiration_date <= ? ",
                                 false,0, Date.today.strftime('%Y-%m-%d'))

  (items || []).each do |item|
    message = "#{item.drug_name} with lot number: #{item.lot_number} for #{item.patient_name} has expired."
    create_alert(message, "expired item", item.pap_identifier)
  end
end

def create_alert(message, type, key)
  news = News.where("message = ? AND news_type = ? AND resolved = ?",message, type,false).first
  news = News.new if news.blank?
  news.message = message
  news.news_type = type
  news.refers_to = key
  news.save
end

start
