namespace :manufacturers do

  desc "Load RxMAGIC manufacturer data"

  task load: :environment do
    require Rails.root.join('scripts', 'load_manufacturers.rb')
  end
end
