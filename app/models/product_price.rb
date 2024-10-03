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
class ProductPrice < ApplicationRecord
  PER_UNIT = 'per_unit'.freeze
  RECURRING_USAGE_TYPE = 'licensed'.freeze
  STRIPE_ID_PREFIX = 'product_price_'.freeze
  LIFETIME = 'lifetime'.freeze
  RECURRING = 'recurring'.freeze
  PAYMENT = 'payment'.freeze
  SUBSCRIPTION = 'subscription'.freeze
  INTERVAL_DROPDOWN_OPTIONS = %w[lifetime day week month year]
  enum interval: { lifetime: 0, day: 1, week: 2, month: 3, year: 4 }

  belongs_to :product

  scope :active, -> {
    where(is_active: true)
  }

  def create_stripe_price
    return if product.stripe_product_id.nil? || stripe_price_id.present?
    params = {
        currency: currency,
        active: is_active,
        metadata: metadata,
        lookup_key: lookup_key,
        nickname: name,
        product: product.stripe_product_id,
        billing_scheme: PER_UNIT,
        unit_amount: price,
        recurring: calculate_recurring
      }
    price = Stripe::Price.create(params)
    update_column(:stripe_price_id, price.id)
    price
  rescue Stripe::InvalidRequestError => e
    # TODO: Somehow make this email or track the errors somehow and notify me
  rescue Stripe::StripeError => e
    # TODO: log that an error occurred somewhere
  end

  def update_stripe_price(params)
    Stripe::Price.update(params)
  rescue Stripe::InvalidRequestError => e
    # TODO: Somehow make this email or track the errors somehow and notify me
  rescue Stripe::StripeError => e
    # TODO: log that an error occurred somewhere
  end

  def metadata
    {
      product_price_id: id,
      product_id: product_id
    }
  end

  # Stripe has a recurring object on the Price object
  # Should return an object like
  # "recurring": {
  #   "aggregate_usage": null,
  #   "interval": "month",
  #   "interval_count": 1,
  #   "trial_period_days": null,
  #   "usage_type": "licensed"
  # },
  # Return nil if type is one_time: 0

  def calculate_recurring
    return if lifetime?
    {
      # aggregate_usage is for when usage_type "metered"
      # aggregate_usage is not needed when usage_type is "licensed"
      # aggregate_usage: nil,
      interval: interval,
      interval_count: 1,
      # TODO: How to handle trial periods
      trial_period_days: nil,
      usage_type: RECURRING_USAGE_TYPE
    }
  end

  def mode
    if lifetime?
      PAYMENT
    else
      SUBSCRIPTION
    end
  end

  def lifetime?
    interval == LIFETIME
  end

  def for_subscription?
    !!product.for_subscription
  end
end
