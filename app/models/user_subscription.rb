# == Schema Information
#
# Table name: user_subscriptions
#
#  id                     :bigint           not null, primary key
#  user_id                :bigint           not null
#  stripe_subscription_id :string(128)
#  status                 :string(128)
#  description            :string
#  interval               :string
#  current_period_start   :integer
#  current_period_end     :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# If there is no stripe_subscription_id, it means it was a one_time payment and is for the lifetime subscription
class UserSubscription < ApplicationRecord
  FREQUENCIES = {
    MONTHLY: 'monthly'.freeze,
    YEARLY: 'yearly'.freeze,
    LIFETIME: 'lifetime'.freeze,
    CUSTOM: 'custom'.freeze
  }.freeze

  # Stripe subscription status use this form
  # 'active', 'canceled', 'incomplete', 'incomplete_expired', 'trialing', 'past_due', 'unpaid', 'paused'
  STATUSES = {
    ACTIVE: 'active'.freeze,
    CANCELED: 'canceled'.freeze,
    INCOMPLETE: 'incomplete'.freeze,
    INCOMPLETE_EXPIRED: 'incomplete_expired'.freeze,
    TRIALING: 'trialing'.freeze,
    PAST_DUE: 'past_due'.freeze,
    UNPAID: 'unpaid'.freeze,
    PAUSED: 'paused'.freeze
  }

  STRIPE_SUBSCRIPTION_URL = '/v1/subscription_products?subscription='.freeze

  scope :active, -> {
    where(status: STATUSES[:ACTIVE])
      .where('current_period_end > ?', StripeService.get_stripe_time_now)
  }

  belongs_to :user
  belongs_to :product
  belongs_to :product_price

  validates :user, presence: true

  def self.get_subscription_frequency_from_interval(interval)
    case interval
    when 'month'
      TYPES[:MONTHLY]
    when 'year'
      TYPES[:LIFETIME]
    else
      TYPES[:CUSTOM]
    end
  end

  def is_active?
    Time.now <= Time.at(current_period_end)
  end

  def get_subscription_url
    "#{STRIPE_SUBSCRIPTION_URL}#{stripe_subscription_id}"
  end
end
