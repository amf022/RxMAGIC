
class ActivitySheetPdf < Prawn::Document
  def initialize(activities,low_stock,date)
    super({:page_layout => :landscape,:page_size => 'A4' })
    @activities = activities
    @low_stock = low_stock
    @date = date
    header
    text_content
    table_content
    refills
  end

  def header
    text "Pharmacy Activity Sheet", size: 15, style: :bold, :align => :center
  end

  def text_content
    y_position = cursor

    bounding_box([0, y_position], :width => 270) do
      text "Date : #{@date}"
      text "Clinic : #{get_facility_name}"
    end

    bounding_box([550, y_position], :width => 270) do
      text "Pharmacist : "
      text "Student : "
    end

    text "Please complete out all items for each patient with only one medication per line"
  end

  def table_content

    move_down 10
    table(product_rows, :cell_style => {:size => 10}, :column_widths => {0 => 40, 1 => 40,4 => 30,6=>60, 7=>45,10=>50,13=> 70})

  end

  def refills
    move_down 5
    text "Stock meds to be replenished :"

    unless @low_stock.blank?
      move_down 10
      table(items_to_refill, :cell_style => {:borders => []})
    end
  end

  def product_rows
    rows = [[{:content => 'Initials', :rowspan => 2},{:content => 'Rx #', :rowspan => 2},
             {:content => 'Patient Name', :rowspan => 2}, {:content => 'Medication', :rowspan => 2},
             {:content => 'Qty', :rowspan => 2}, {:content => 'Directions', :rowspan => 2},
             {:content => 'Med Source', :colspan => 3, :align => :center},
             {:content => 'PMAP', :colspan => 4,:align => :center},
             {:content => 'Comments', :rowspan => 2, :align => :center}],
            ['Borrowed', 'PMAP','Stock', 'New Med', 'Reorder', 'Dose Change','Re-Enrollment /New App']]


    (@activities || {}).each do |patient_id, patient|
      (patient ||{}).each do |drug_name, record|
        rows << ["",record['prescription'],record['patient_name'], drug_name,record['quantity'],record['directions'],
                 (record['source'].include?('Borrowed') ? {:content => 'X', :align => :center} : ""),
                 (record['source'].include?('PMAP') ? {:content => 'X', :align => :center} : ""),
                 (record['source'].include?('General') ? {:content => 'X', :align => :center} : ""),"",
                 (record['reorder'].blank? ? "" : {:content => 'X', :align => :center}),"","",""]
      end
    end

    return rows
  end

  def items_to_refill
    rows = []
    i = 0

    while i < @low_stock.length  do
     if @low_stock[i+1].blank?
       rows << ["#{i+1}.", title(@low_stock[i]), "", ""]
     else
       rows << ["#{i+1}.", title(@low_stock[i]), "#{i+2  }.", title(@low_stock[i+1])]
     end

     i += 2

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