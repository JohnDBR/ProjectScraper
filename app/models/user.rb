class User < ApplicationRecord
  has_secure_password

  validates :email, :username, presence: true, uniqueness: true
  validates :password, :role, presence: true, on: :create

  before_save :format_downcase

  has_many :tokens, dependent: :destroy
end