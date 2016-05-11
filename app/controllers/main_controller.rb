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

      status = RestClient.post(login_link, {"username" => params[:user][:username], "password" => params[:user][:password]})

      if status.match(/error/i)
        flash[:error][:invalid_credentials] = []
        flash[:error][:invalid_credentials] = status.gsub("Error: ", "")
      else
        session[:user_token] = status
        session[:user] = params[:user][:username]
        redirect_to "/"
      end
    end
  end

  def logout
    config = YAML.load_file("#{Rails.root}/config/application.yml")
    login_link = "#{config["user_management_protocol"]}://#{config["user_management_name"]}:#{config["user_management_password"]}@#{config["user_management_server"]}:#{config["user_management_port"]}#{config["user_management_logout"]}"
    logout_status = RestClient.post(login_link, {"token" => session[:user_token]})

    if logout_status
      session[:user_token] = nil
      session[:user] = nil
      # flash[:notice] = "You have been logged out!"
      redirect_to "/login" and return
    else
    end
  end

end
