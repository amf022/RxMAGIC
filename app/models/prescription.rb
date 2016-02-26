class Prescription < ActiveRecord::Base
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :provider, :foreign_key => :provider_id
  belongs_to :rxconso, :foreign_key => :rxaui

end
