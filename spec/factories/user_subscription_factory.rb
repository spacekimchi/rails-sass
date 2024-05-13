FactoryBot.define do
  factory :user_subscription do
    association :user
    association :product
    association :product_price

    stripe_subscription_id { Faker::Alphanumeric.alphanumeric(number: 20) }
    status { UserSubscription::STATUSES[:ACTIVE] }
    current_period_start { Time.now.to_i }
    current_period_end { 1.month.from_now.to_i }

    trait :lifetime_subscription do
      stripe_subscription_id { nil } # Indicates a lifetime subscription
      status { UserSubscription::STATUSES[:ACTIVE] }
      current_period_start { Time.now.to_i }
      current_period_end { 100.years.from_now.to_i }
    end
  end
end
