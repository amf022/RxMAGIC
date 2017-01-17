#This module includes all functions that may come in handy to do avoid code repetitions

module Misc

  def calculate_check_digit(number)
    # This is Luhn's algorithm for checksums
    # http://en.wikipedia.org/wiki/Luhn_algorithm
    # Same algorithm used by PIH (except they allow characters)
    number = number.to_s
    number = number.split(//).collect { |digit| digit.to_i }
    parity = number.length % 2

    sum = 0
    number.each_with_index do |digit,index|
      luhn_transform = ((index + 1) % 2 == parity ? (digit * 2) : digit)
      luhn_transform = luhn_transform - 9 if luhn_transform > 9
      sum += luhn_transform
    end

    checkdigit = (sum * 9 )%10
    return checkdigit
  end

  def create_bottle_label(item,bottle_id,expiration_date,lot_number,type,patient_name=nil )

    label = ZebraPrinter::StandardLabel.new
    label.font_size = 4
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.left_margin = 50
    label.draw_barcode(610,30,1,1,3,6,80,false,"#{bottle_id}")
    label.draw_multi_text("#{item}", {:column_width => 570})
    label.draw_multi_text("Patient: #{patient_name}",{:column_width => 570}) unless patient_name.blank?
    label.draw_multi_text("Type: #{type}",{:column_width => 570})
    label.draw_multi_text("Bottle #:#{Misc.dash_formatter(bottle_id)}",{:column_width => 570})
    label.draw_multi_text("Lot #:#{lot_number} ",{:column_width => 570})
    label.draw_multi_text("Exp:#{expiration_date.strftime('%m/%y')}", {:column_width => 570})
    label.print(1)

  end

  def create_dispensation_label(item,quantity,manufacturer,directions,patient_name,prescriber,rx_id)

    label = ZebraPrinter::StandardLabel.new
    label.font_size = 4
    label.font_horizontal_multiplier = 1
    label.font_vertical_multiplier = 1
    label.left_margin = 50
    label.draw_text("Rx:#{rx_id}",450,10,0,4,1,1,true)
    label.draw_multi_text("#{get_facility_name}")
    label.draw_multi_text("Phone: #{get_facility_phone}") unless get_facility_phone.blank?
    label.draw_multi_text("Patient: #{patient_name}")
    label.draw_multi_text("Physician: #{prescriber}")
    label.draw_multi_text("#{item}")
    label.draw_multi_text("Dir : #{directions}")
    label.draw_multi_text("QTY : #{quantity}")
    label.draw_multi_text("Mfn :#{manufacturer}")
    label.draw_text("#{Date.today.strftime('%m/%d/%Y')}",450,366,0,4,1,1,true)
    label.print(1)

  end

  def self.dash_formatter(id)
    return "" if id.blank?
    if id.length > 9
      return id[0..(id.length/3)] + "-" +id[1 +(id.length/3)..(id.length/3)*2]+ "-" +id[1 +2*(id.length/3)..id.length]
    else
      return id[0..(id.length/2)] + "-" +id[1 +(id.length/2)..id.length]
    end
  end

  def self.source_of_meds(patient_id,inventory_id)

    if inventory_id.match(/g/i)
      return "General"
    else
      pmap_med = PmapInventory.where("pap_identifier = ? AND voided = ?", inventory_id, false).pluck(:patient_id)

      if pmap_med.blank?
        return "General"
      else
        if pmap_med.include?(patient_id)
          return "PMAP"
        else
          return "Borrowed"
        end
      end
    end
  end

  def self.reorder_meds(patient_id, drug_code)

    max_date = PmapInventory.select("MAX(date_received) as date_received").where("voided = ? AND rxaui = ? AND patient_id = ?",
                                                                                 false, drug_code, patient_id)

    if max_date.blank?
      return false
    else
      pmap_med = PmapInventory.select("sum(received_quantity) as received_quantity, sum(current_quantity) as
                                       current_quantity").where("voided = ? AND rxaui = ? AND patient_id =  ? AND
                                       date_received = ?", false, drug_code, patient_id,max_date.first.date_received)

      (pmap_med || []).each do |main_item|
        if (main_item.current_quantity.to_f/main_item.received_quantity.to_f) < 0.50
          return true
        end
      end
      return false
    end
  end

  def self.calculate_gn_thresholds

    sets = get_threshold_sets

    items = GeneralInventory.where("voided = ?", false).group(:rxaui).sum(:current_quantity)

    (items || []).each do |rxaui, count|
      (sets || []).each do |id,threshold|
        if threshold["items"].include? rxaui
          threshold["count"] += count
        end
      end
    end

    (sets || []).each do |id,set|
      set["items"] = []
    end
    return sets
  end

  private

  def get_facility_name
    YAML.load_file("#{Rails.root}/config/application.yml")['facility_name']
  end

  def get_facility_phone
    YAML.load_file("#{Rails.root}/config/application.yml")['facility_phone_number']
  end

  def self.get_threshold_sets
    sets = DrugThresholdSet.where("voided = ? ", false).pluck(:threshold_id,:rxaui)

    mappings = {}
    sets.each do | element|
      if mappings[element[0]].blank?
        threshold = DrugThreshold.find(element[0])
        mappings[element[0]] = {"items" => [], "count" => 0,"name" => threshold.drug_name,"threshold" => threshold.threshold}
      end
      mappings[element[0]]["items"] << element[1]
    end

    return mappings
  end
end


