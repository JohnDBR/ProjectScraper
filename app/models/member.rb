class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group

  after_destroy :delete_empty_group

  protected
  def delete_empty_group
    self.group.destroy if self.group.members.empty?
  end
end
