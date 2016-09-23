class User < ActiveRecord::Base

  attr_accessor :password
  validates_confirmation_of :password
  has_one :user_credential, :foreign_key => :user_id

  def fullname
    (self.first_name + " " + self.last_name).titleize
  end

  def password_hash
    self.user_credential.password_hash rescue ""
  end

  def password_salt
    self.user_credential.password_salt rescue ""
  end

  def self.authenticate(username, password)

    user = User.where(username: username).first

    user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)

  end

end
