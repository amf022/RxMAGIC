class Provider < ActiveRecord::Base

  def fullname
    (self.first_name rescue '') + " " + (self.last_name rescue '')
  end

end
