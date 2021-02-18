FactoryBot.define do
  factory :sale do
    sale_date { DateTime.now }
    client_id { create(:client).id }
  end
end
