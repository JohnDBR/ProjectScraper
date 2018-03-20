class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group

  after_destroy :delete_empty_group
  before_save :format_downcase

  protected
  def delete_empty_group
    self.group.destroy if self.group.members.empty?
  end

  def format_downcase
    self.alias.downcase!
  end
end
