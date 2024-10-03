# == Schema Information
#
# Table name: products
#
#  id                :bigint           not null, primary key
#  stripe_product_id :string(128)
#  name              :string(128)      not null
#  description       :string
#  for_subscription  :boolean          default(TRUE), not null
#  is_active         :boolean          default(TRUE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class Product < ApplicationRecord
  STRIPE_ID_PREFIX = 'product_'.freeze
  has_many :product_prices, dependent: :destroy

  scope :active, -> {
    where(is_active: true)
  }

  scope :for_subscriptions, -> {
    where(for_subscription: true)
  }

  def for_subscription?
    !!for_subscription
  end

  def generate_stripe_product_id
    time_now = Time.now.utc
    formatted_time = time_now.strftime("%Y%m%d%H%M%S")
    "#{STRIPE_ID_PREFIX}#{formatted_time}_#{id}"
  end

  def create_stripe_product
    return if stripe_product_id.present?
    generated_stripe_product_id = generate_stripe_product_id
    Stripe::Product.create(
      {
        id: generated_stripe_product_id,
        name: name,
        description: description,
        active: is_active,
        metadata: metadata
      }
    )
    update_column(:stripe_product_id, generated_stripe_product_id)
  rescue Stripe::InvalidRequestError => e
    # TODO: Somehow make this email or track the errors somehow and notify me
  rescue Stripe::StripeError => e
    # TODO: log that an error occurred somewhere
  end

  def update_stripe_product(params)
    Stripe::Product.update(params)
  rescue Stripe::InvalidRequestError => e
    # TODO: Somehow make this email or track the errors somehow and notify me
  rescue Stripe::StripeError => e
    # TODO: log that an error occurred somewhere
  end

  def metadata
    {
      product_id: id,
      for_subscription: for_subscription?
    }
  end
end
