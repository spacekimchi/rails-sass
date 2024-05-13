FactoryBot.define do
  factory :product_price do
    association :product
    stripe_price_id { Faker::Alphanumeric.alphanumeric(number: 20) }
    name { Faker::Commerce.product_name }
    price { Faker::Number.between(from: 1000, to: 10000) } # Represented in cents
    is_active { true }
    interval { ProductPrice.intervals.keys.sample }
    description { Faker::Lorem.sentence }
    lookup_key { Faker::Alphanumeric.alphanumeric(number: 10) }
    currency { 'usd' }

    trait :inactive do
      is_active { false }
    end
  end
end
