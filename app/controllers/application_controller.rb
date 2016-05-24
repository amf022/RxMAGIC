class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate, :except => ['login','/printable_activity_sheet']
  def print_and_redirect(print_url, redirect_url, message = "Printing label ...", show_next_button = false, patient_id = nil)
    #Function handles redirects when printing labels
    @print_url = print_url
    @redirect_url = redirect_url
    @message = message
    @show_next_button = show_next_button
    render :layout => false
  end

  def authenticate

    if session[:user_token].blank?
      redirect_to "/login" and return
    else
      config = YAML.load_file("#{Rails.root}/config/application.yml")
      auth_link = "#{config["user_management_protocol"]}://#{config["user_management_name"]}:#{config["user_management_password"]}@#{config["user_management_server"]}:#{config["user_management_port"]}#{config["user_management_authenticate"]}"
      auth_status = RestClient.post(auth_link, {"token" => session[:user_token]})

      if auth_status == "true"
        return true
      else
        redirect_to "/login" and return
      end
    end
  end

end
