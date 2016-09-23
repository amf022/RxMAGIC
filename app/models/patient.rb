class Patient < ActiveRecord::Base

  def fullname
    (self.first_name + " " + self.last_name).titleize
  end

  def patient_gender
    self.gender == "F" ? 'Female' : 'Male'
  end

  def age
    age_in_days = (Date.today - self.birthdate).to_i

    if age_in_days < 31
      return age_in_days.to_s + " days"
    elsif age_in_days < 365
      years = (Date.today.year - self.birthdate.year)
      months = (Date.today.month - self.birthdate.month)
      return ((years * 12) + months).to_s + " months"
    else
      return (age_in_days / 365)
    end
  end

  def birthdate_formatted
    self.birthdate.to_date.strftime("%b %d, %Y") rescue "Unknown"
  end

end
