# == Schema Information
#
# Table name: user_subscriptions
#
#  id                     :bigint           not null, primary key
#  user_id                :bigint           not null
#  product_id             :bigint
#  product_price_id       :bigint
#  stripe_subscription_id :string(128)
#  status                 :string
#  current_period_start   :bigint
#  current_period_end     :bigint
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
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

    trait :canceled do
      status { UserSubscription::STATUSES[:CANCELED] }
    end
  end
end
