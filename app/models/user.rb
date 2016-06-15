class User < ActiveRecord::Base

  def fullname
    (self.first_name + " " + self.last_name).titleize
  end

end
