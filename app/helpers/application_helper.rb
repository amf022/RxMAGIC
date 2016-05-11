module ApplicationHelper
  def facility_name
    YAML.load_file("#{Rails.root}/config/application.yml")['facility_name']
  end
  def manufacturers
    JSON.parse(File.open("#{Rails.root}/app/assets/data/manufacturers.json").read)
  end
  def logged_user
    session[:user]
  end
end
