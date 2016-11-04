class DrugThresholdSet < ActiveRecord::Base
  belongs_to :drug_threshold, :foreign_key => :threshold_id
  belongs_to :rxnconso, :foreign_key => :rxaui
  validates_associated :drug_threshold
  validates_associated :rxnconso

  def self.create_new_set(rxcui,threshold_id)
    items = Rxnconso.find_by_sql("SELECT RXAUI FROM RXNCONSO where TTY = 'PSN' AND RXCUI in (SELECT RXCUI1 FROM RXNREL
                                  where RXCUI2 = '#{rxcui}' AND RELA = 'constitutes')")

    (items || []).each do |item|
      DrugThresholdSet.create({:threshold_id => threshold_id, :rxaui => item.RXAUI})
    end
  end
end
