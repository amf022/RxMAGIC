namespace :stress_test_data do

  desc "Creating dummy stress test data for RxMAGIC"

  task generate: :environment do
    require Rails.root.join('scripts', 'stress_test_data.rb')
  end
end
