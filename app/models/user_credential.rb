class UserCredential < ActiveRecord::Base
  belongs_to :user, :foreign_key => :user_id

  attr_accessor :password
  validates_confirmation_of :password

  before_save :encrypt_password

  def encrypt_password
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

end
