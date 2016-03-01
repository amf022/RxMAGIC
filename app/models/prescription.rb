class Prescription < ActiveRecord::Base
  belongs_to :patient, :foreign_key => :patient_id
  belongs_to :provider, :foreign_key => :provider_id
  belongs_to :rxnconso, :foreign_key => :rxaui

  def patient_name
    self.patient.fullname
  end

  def prescribed_by
    self.provider.fullname
  end
end
