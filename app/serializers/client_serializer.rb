# frozen_string_literal: true

class ClientSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :email,
             :cellphone,
             :description,
             :created_at,
             :updated_at
end
