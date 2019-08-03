class MemberSerializer < ActiveModel::Serializer
  attributes :id, :admin, :alias, :group_id, :created_at, :updated_at

  belongs_to :user
end
