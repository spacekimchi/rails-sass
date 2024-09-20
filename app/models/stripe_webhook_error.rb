# == Schema Information
#
# Table name: stripe_webhook_errors
#
#  id                 :bigint           not null, primary key
#  message            :string
#  stripe_customer_id :string
#  event_object       :json
#  event_type         :string
#  is_resolved        :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class StripeWebhookError < ApplicationRecord
  TYPES = {
    CUSTOMER: 'CUSTOMER'.freeze,
    PAYMENT_INTENT: 'PAYMENT_INTENT'.freeze,
    PAYMENT_METHOD: 'PAYMENT_METHOD'.freeze,
    INVOICE: 'INVOICE'.freeze,
    PLAN: 'PLAN'.freeze,
    PRICE: 'PRICE'.freeze,
    SUBSCRIPTION: 'SUBSCRIPTION'.freeze,
    PRODUCT: 'PRODUCT'.freeze,
    UNKNOWN: 'UNKNOWN'.freeze
  }.freeze

  def user
    User.find_by(id: stripe_customer_id)
  end
end
