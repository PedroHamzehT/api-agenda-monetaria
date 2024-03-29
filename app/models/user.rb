# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates_presence_of :email, :name
  validates_uniqueness_of :email

  has_many :clients
  has_many :products
  has_many :sales, through: :clients
end
