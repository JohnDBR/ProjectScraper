class User < ApplicationRecord
  #has_secure_password

  validates :username, presence: true, uniqueness: true #:email,
  # validates :role, presence: true, on: :create #:password,

  before_save :format_downcase

  has_many :tokens, dependent: :destroy
  belongs_to :storage, optional: true, dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :groups, :through => :members

  protected 
  def format_downcase
    #self.email.downcase!
    self.username.downcase!
  end
end