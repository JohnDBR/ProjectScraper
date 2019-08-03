class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :storage_id, :created_at, :updated_at, :members

  # has_many :members
  def members
    ActiveModel::Serializer::CollectionSerializer.new(self.object.members, serializer:MemberSerializer)
  end
end
