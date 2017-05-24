class InventoryPdf < Prawn::Document
    def initialize(records ,title,date, headings)
      super({:page_layout => :landscape,:page_size => 'A4' })
      @title = title
      @records=records
      @date = date
      @headings = headings
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
        text "Clinic : #{get_facility_name}"
        text "Date : #{@date}"
      end

    end

    def table_content

      move_down 10
      table(product_rows, :header => true,:width => 750, :position => :center)

    end

    def product_rows
      rows = [@headings.map{|x| {:content => (x.gsub('_', ' ').titleize), :background_color => "CCCCCC"}}]

      (@records || []).each do |row_details|
        row = []
        (@headings || []).each do |title|
          row << row_details[title]
        end
        rows << row
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