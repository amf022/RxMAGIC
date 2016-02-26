class PapInventory < ActiveRecord::Base
  belongs_to :rxconso, :foreign_key => :rxaui
end
