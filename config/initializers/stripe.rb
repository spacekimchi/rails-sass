Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLIC_KEY'],
  secret_key: ENV['STRIPE_PRIVATE_KEY']
}
Stripe.api_key = Rails.configuration.stripe[:secret_key]
