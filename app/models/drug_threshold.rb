class DrugThreshold < ActiveRecord::Base
  belongs_to :rxconso, :foreign_key => :rxcui
end
