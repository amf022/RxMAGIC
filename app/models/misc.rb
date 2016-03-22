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
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(610,10,1,1,4,10,80,false,"#{bottle_id}")
    label.draw_multi_text("#{item}", {})
    label.draw_multi_text("#{patient_name}")
    label.draw_multi_text("Type : #{type}")
    label.draw_multi_text("Bottle # :#{bottle_id} ")
    label.draw_multi_text("Lot # :#{lot_number} ")
    label.draw_multi_text("Exp :#{expiration_date.strftime('%m/%y')}", {})
    label.print(1)

  end

end