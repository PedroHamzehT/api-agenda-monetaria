class ProductSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :value,
             :description,
             :created_at,
             :updated_at
end
