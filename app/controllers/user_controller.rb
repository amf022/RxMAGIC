class UserController < ApplicationController
  def index
  end

  def show
  end

  def new
  end

  def edit
  end

  def create

  end

  def create_user_role
    if request.post?
      user = User.where(username: params[:user_role][:user_name]).first_or_initialize
      user.first_name = params[:user_role][:first_name]
      user.last_name = params[:user_role][:last_name]
      user.user_role = params[:user_role][:user_role]

      if user.save
        redirect_to "/"
      else
        flash[:error] = user.errors
        redirect_to "/new_user_role"
      end
    end
  end


  def login
    #The login process can be done in three ways.Locally, remotely with User MGMT and with LDAP
    if request.post?
      config = YAML.load_file("#{Rails.root}/config/application.yml")

      case config["authentication"].downcase

        when "local"
          if User.authenticate(params[:user][:username], params[:user][:password])
            session[:user_token] = (0...5).map { (65 + rand(26)).chr }.join
          else
            flash[:errors] = {} if flash[:errors].blank?
            flash[:errors]["invalid_credentials"] = ["Wrong username/password combination"]
          end
        when "ldap"
          ldap = Net::LDAP.new
          ldap.host = config["ldap_host"]
          ldap.port = config["ldap_port"]
          ldap.auth params[:user][:username], params[:user][:password]
          if ldap.bind
            # authentication succeeded
            session[:user_token] = (0...5).map { (65 + rand(26)).chr }.join
          else
            flash[:errors] = {} if flash[:errors].blank?
            flash[:errors]["invalid_credentials"] = ["Wrong username/password combination"]
          end
        else
          login_link = "#{config["user_management_protocol"]}://#{config["user_management_name"]}:#{config["user_management_password"]}@#{config["user_management_server"]}:#{config["user_management_port"]}#{config["user_management_login"]}"
          post_params = {"username" => params[:user][:username], "password" => params[:user][:password]}

          status = RestClient::Request.execute(:url => login_link,:payload => post_params, :method => :post, :verify_ssl => false )

          if status.match(/error/i)
            flash[:errors] = {} if flash[:errors].blank?
            flash[:errors]["invalid_credentials"] = [status.gsub("Error: ", "")]
          else
            session[:user_token] = status
          end
      end

      if !session[:user_token].blank?
        session[:user] = params[:user][:username]
        user_role = User.find_by_username(params[:user][:username])
        if user_role.blank?
          redirect_to "/new_user_role"
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


end
