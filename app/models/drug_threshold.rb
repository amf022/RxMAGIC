class DrugThreshold < ActiveRecord::Base
  belongs_to :rxnconso, :foreign_key => :rxaui
  has_many :drug_threshold_sets, :foreign_key => :threshold_id
  validates :threshold, :presence => true
  validates :threshold, :numericality => { :only_integer => true }
  validates :threshold, :numericality => { :greater_than => 0 }
  validates_associated :rxnconso

  def drug_name
    #this method handles the need to access the drug name associated to the inventory entry
    self.rxnconso.STR.humanize.gsub(/\b('?[a-z])/) { $1.capitalize } rescue ""
  end
end
