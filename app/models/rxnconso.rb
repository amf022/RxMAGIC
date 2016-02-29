class Rxnconso < ActiveRecord::Base
  self.table_name = 'RXNCONSO'
  self.primary_key = 'RXAUI'

  def name
    return self.STR
  end
end
