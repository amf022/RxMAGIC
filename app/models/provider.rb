class Provider < ActiveRecord::Base

  def fullname
    self.first_name + " " + self.last_name
  end

end
