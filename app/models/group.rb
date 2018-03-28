class Group < ApplicationRecord
  before_save :format_downcase
  
  has_many :links, dependent: :destroy
  belongs_to :storage, optional: true, dependent: :destroy
  has_many :members, dependent: :destroy
  has_many :users, :through => :members

  protected
  def format_downcase
    self.name.downcase!
  end
end
