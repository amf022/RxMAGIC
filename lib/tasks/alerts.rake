namespace :test_data do

  desc "Creating system alerts for RxMAGIC"

  task generate: :environment do
    require Rails.root.join('scripts', 'alerts.rb')
  end
end
