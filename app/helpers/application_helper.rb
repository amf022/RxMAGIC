module ApplicationHelper
  def facility_name
    YAML.load_file("#{Rails.root}/config/application.yml")['facility_name']
  end
  def pmap_manufacturers
    Manufacturer.where("has_pmap = ?", true).collect{|x| x.name} rescue []
  end
  def logged_user
    current_user.username rescue ""
  end
  def logged_user_name
    current_user.fullname rescue ""
  end
  def suppress_expiry_alert
    YAML.load_file("#{Rails.root}/config/application.yml")['suppress_expiry_alert'] rescue false
  end
  def suppress_prescription_alert
    YAML.load_file("#{Rails.root}/config/application.yml")['suppress_prescription_alert'] rescue false
  end
  def suppress_pmap_alert
    YAML.load_file("#{Rails.root}/config/application.yml")['suppress_pmap_alert'] rescue false
  end

end
