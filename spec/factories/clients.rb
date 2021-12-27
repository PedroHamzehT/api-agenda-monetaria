# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    description { 'Some description' }
    user_id { create(:user).id }
  end
end
