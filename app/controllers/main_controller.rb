class MainController < ApplicationController

  def index
    #This is the landing page for the application
    @alerts = News.where({:resolved => false}).order(created_at: :desc)
  end

  def dashboard
    #This is the function that handles the dashboard page
    render :layout => false
  end

	def about
		#This page displays application details
  end

  def activity_sheet
    #code block for generating activity sheet

    report_date = params[:date].to_date rescue Date.today
    @date = report_date.strftime("%b %d, %Y")
    dispensations = Dispensation.where("voided = ? AND dispensation_date BETWEEN ? AND ?", false,
                                       report_date.strftime("%Y-%m-%d 00:00:00"),
                                       report_date.strftime("%Y-%m-%d 23:59:59"))

    @records = view_context.activities(dispensations)

    low_stock_items = News.where("date_resolved = ? AND resolved = ? AND resolution = ? AND news_type = ?",
                                 report_date.strftime("%Y-%m-%d"), true,'Added to activity sheet',
                                 "low general stock").pluck(:refers_to)
    @low_stock = Rxnconso.where("RXAUI in (?)", low_stock_items).pluck(:STR)

    @clinic = YAML.load_file("#{Rails.root}/config/application.yml")['facility_name']

    respond_to do |format|
      format.html
      format.pdf do
        pdf = ActivitySheetPdf.new(@records, @low_stock,@date)
        send_data pdf.render, filename: "activity_sheet_#{report_date}.pdf", type: 'application/pdf'
      end
      format.docx { headers["Content-Disposition"] = "attachment; filename=\"activity_sheet_#{report_date}.docx\"" }
    end

  end

  def printable_activity_sheet
    #code block for generating printable activity sheet

    report_date = params[:date].to_date rescue Date.today
    @date = report_date.strftime("%b %d, %Y")
    dispensations = Dispensation.where("voided = ? AND dispensation_date BETWEEN ? AND ?", false,
                                       report_date.strftime("%Y-%m-%d 00:00:00"),
                                       report_date.strftime("%Y-%m-%d 23:59:59"))

    @records = view_context.activities(dispensations)

    low_stock_items = News.where("date_resolved = ? AND resolved = ? AND resolution = ? AND news_type = ?",
                                 report_date.strftime("%Y-%m-%d"), true,'Added to activity sheet',
                                 "low general stock").pluck(:refers_to)
    @low_stock = Rxnconso.where("RXAUI in (?)", low_stock_items).pluck(:STR)

    render :layout => false
  end

  def print_activity_sheet
    #deprecated code

    report_date = params[:date].to_date rescue Date.today
    pdf_filename = "activity_sheet_#{report_date}.pdf"
    pdf_path = File.join(Rails.root, "tmp/activity_sheet_#{report_date}.pdf")
    new_thread = Thread.new {
      Kernel.system("wkhtmltopdf http://127.0.0.1:3000/printable_activity_sheet/#{report_date} #{pdf_path}")
      sleep(5)
    }

    while (!File.exist?(pdf_path))

    end

    send_file(pdf_path, :filename => pdf_filename, :type => "application/pdf")
  end
  def contact

    if request.method == "POST"
      Contact.report_contact(params[:contact][:name],params[:contact][:email],params[:contact][:message]).deliver
      flash[:success] = "Message sent to RxMAGIC Team"
    end

  end

  def faq
    #This page will display frequently asked questions
  end

  def custom_report

    if request.post?
      case params[:report][:duration]
        when 'daily'
          @title = "Daily Inventory and Dispension Report for #{params[:report][:start_date].to_date.strftime('%d %B, %Y')}"
          start_date = params[:report][:start_date].to_date.strftime('%Y-%m-%d 00:00:00')
          end_date = params[:report][:start_date].to_date.strftime('%Y-%m-%d 23:59:59')
 
        when 'monthly'
          @title = "Inventory and Dispensation Report for #{params[:report][:start_date].to_date.strftime('%B %Y')}"
          start_date = params[:report][:start_date].to_date.beginning_of_month.strftime('%Y-%m-%d 00:00:00')
          end_date = params[:report][:start_date].to_date.end_of_month.strftime('%Y-%m-%d 23:59:59')

        when 'range'
          @title = "Inventory and Dispensation Report from #{params[:report][:start_date].to_date.strftime('%d %B, %Y')}
         to #{params[:report][:end_date].to_date.strftime('%d %B, %Y')}"
          start_date = params[:report][:start_date].to_date.strftime('%Y-%m-%d 00:00:00')
          end_date = params[:report][:end_date].to_date.strftime('%Y-%m-%d 23:59:59')

      end

      prescriptions = Prescription.select("count(rx_id) as rx_id,sum(quantity) as quantity,sum(amount_dispensed) as amount_dispensed,
                                          rxaui").where("voided = ? and date_prescribed BETWEEN ? and ?",
                                                        false, start_date, end_date).group("rxaui")

      dispensations = Dispensation.find_by_sql("select rxaui, sum(d.quantity) as quantity from dispensations as d left join
                                       prescriptions p on d.rx_id=p.rx_id where dispensation_date > '#{end_date}' and
                                       d.voided =0 and p.voided =0 group by rxaui, inventory_id")


      inventory = GeneralInventory.find_by_sql("SELECT inventory.rxaui,sum(current_quantity)
                                                as current_quantity FROM (Select rxaui, gn_identifier as identifier,
                                                current_quantity from general_inventories where voided = 0 and
                                                date_received <= '#{end_date}' UNION Select rxaui, pap_identifier as
                                                identifier, current_quantity from pmap_inventories where voided = 0
                                                and date_received <= '#{end_date}') as inventory group by inventory.rxaui")

      @records = view_context.compile_report(prescriptions,inventory, dispensations)


    else
      @title = "Inventory and Dispensation Report"
    end

    respond_to do |format|
      format.html do

      end
    end
  end

  def report

  end
end
