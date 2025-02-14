class ApplicationSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :deleted_at
end
