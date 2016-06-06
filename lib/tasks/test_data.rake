namespace :test_data do

  desc "Creating dummy data for RxMAGIC"

  task generate: :environment do
    require Rails.root.join('db', 'test_data.rb')
  end
end
