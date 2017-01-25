def start
  names = JSON.parse(File.open("#{Rails.root}/app/assets/data/manufacturers.json").read)

  (names || []).each do |manufacturer|
    mfn = Manufacturer.find_by_name(manufacturer[1]).id rescue nil
		unless mfn.blank?
	    PmapInventory.where("manufacturer = ?", manufacturer[0]).update_all(manufacturer: mfn)
		end
  end
end

start
