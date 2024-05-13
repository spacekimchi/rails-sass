FactoryBot.define do
  factory :product do
    stripe_product_id { Faker::Alphanumeric.alphanumeric(number: 20) }
    name { Faker::Commerce.product_name }
    description { Faker::Lorem.sentence }
    for_subscription { [true, false].sample }
    is_active { true }

    trait :for_subscription do
      for_subscription { true }
    end

    trait :for_payment do
      for_subscription { false }
    end

    trait :inactive do
      is_active { false }
    end
  end
end
