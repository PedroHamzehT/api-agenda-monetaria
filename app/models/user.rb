class User < ApplicationRecord
  has_secure_password

  validates_presence_of :email, :name

  has_many :clients
end
