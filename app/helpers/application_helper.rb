module ApplicationHelper
  def facility_name
    YAML.load_file("#{Rails.root}/config/application.yml")['facility_name']
  end
end
