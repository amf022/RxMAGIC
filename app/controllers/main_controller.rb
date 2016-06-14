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

  def login
    if request.post?
      config = YAML.load_file("#{Rails.root}/config/application.yml")
      login_link = "#{config["user_management_protocol"]}://#{config["user_management_name"]}:#{config["user_management_password"]}@#{config["user_management_server"]}:#{config["user_management_port"]}#{config["user_management_login"]}"
      post_params = {"username" => params[:user][:username], "password" => params[:user][:password]}

      status = RestClient::Request.execute(:url => login_link,:payload => post_params, :method => :post, :verify_ssl => false )

      if status.match(/error/i)
        flash[:errors] = {} if flash[:errors].blank?
        flash[:errors]["invalid_credentials"] = [status.gsub("Error: ", "")]
      else
        session[:user_token] = status
        session[:user] = params[:user][:username]
        user_role = UserRole.find_by_username(params[:user][:username])
        if user_role.blank?
          redirect_to "/user_role/new"
        else
          session[:user_role] = user_role.user_role
          redirect_to "/"
        end
      end
    end
  end

  def logout
    config = YAML.load_file("#{Rails.root}/config/application.yml")
    login_link = "#{config["user_management_protocol"]}://#{config["user_management_name"]}:#{config["user_management_password"]}@#{config["user_management_server"]}:#{config["user_management_port"]}#{config["user_management_logout"]}"
    logout_status = RestClient::Request.execute(:url => login_link, :payload => {"token" => session[:user_token]}, :method => :post, :verify_ssl => false )

    if logout_status
      session[:user_token] = nil
      session[:user] = nil
      # flash[:notice] = "You have been logged out!"
      redirect_to "/login" and return
    else
    end
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

    respond_to do |format|
      format.html
      format.pdf do
        pdf = ActivitySheetPdf.new(@records, @low_stock,@date)
        send_data pdf.render, filename: "activity_sheet_#{report_date}.pdf", type: 'application/pdf'
      end
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
      CSV.open("#{Rails.root}/log/reports.csv", "ab") do |csv|
        csv << [params[:contact][:name],params[:contact][:email],Time.now,params[:contact][:message] ]
      end
      flash[:success] = "Message sent to RxMAGIC Team"
    end

  end
end
