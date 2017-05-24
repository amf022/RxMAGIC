
class InventoryReportPdf < Prawn::Document
  def initialize(records ,title,duration)
    super({:page_layout => :landscape,:page_size => 'A4' })
    @title = title
    @records=records
    header
    text_content
    table_content
  end

  def header
    text "#{@title}", size: 15, style: :bold, :align => :center
  end

  def text_content
    y_position = cursor

    bounding_box([0, y_position], :width => 270) do
      text "Duration : #{@date}"
      text "Clinic : #{get_facility_name}"
    end

  end

  def table_content

    move_down 10
    table(product_rows, :column_widths => {0 => 300, 1 => 120,2 => 200,3=>120}, :header => true)

  end

  def product_rows
    rows = [[{:content => 'Item', :background_color => "CCCCCC"},
             {:content => 'Stock Quantity', :align => :center, :background_color => "CCCCCC"},
             {:content => 'Amount Prescribed (# of Rx)', :align => :center, :background_color => "CCCCCC"},
             {:content => 'Amount Dispensed', :align => :center, :background_color => "CCCCCC"}]]

    (@records || []).each do |rxaui,record|
      rows << [record['drug_name'].to_s, {:content => record['stock'].to_s, :align => :center},
               {:content => "#{record['amount_prescribed'].to_s}  (#{record['rx_num'].to_s})", :align => :center},
               {:content => record['amount_dispensed'].to_s, :align => :center}]

    end

    return rows
  end

  private

  def title(str)
    str.humanize.gsub(/\b('?[a-z])/) { $1.capitalize } rescue ""
  end

  def get_facility_name
    YAML.load_file("#{Rails.root}/config/application.yml")['facility_name']
  end
end