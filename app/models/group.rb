class Group < ApplicationRecord
  has_many :members, dependent: :destroy
  has_many :users, :through => :members

  before_save :format_downcase

  protected
  def format_downcase
    self.name.downcase!
  end
end
