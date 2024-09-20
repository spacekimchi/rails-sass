# == Schema Information
#
# Table name: product_prices
#
#  id              :bigint           not null, primary key
#  product_id      :bigint           not null
#  stripe_price_id :string(128)
#  name            :string(128)      not null
#  price           :integer          default(0), not null
#  is_active       :boolean          default(TRUE), not null
#  interval        :integer          not null
#  description     :string
#  lookup_key      :string(128)
#  currency        :string           default("usd")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
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
