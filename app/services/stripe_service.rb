class StripeService
  INVOICE = 'invoice'.freeze
  ONE_TIME = 'one_time'.freeze
  PAYMENT = 'payment'.freeze
  RECURRING = 'recurring'.freeze
  SUBSCRIPTION = 'subscription'.freeze
  ERROR = 'error'.freeze

  def self.get_time(stripe_date)
    Time.at(stripe_date)
  end

  def self.get_datetime(stripe_date)
    Time.at(stripe_date).to_datetime
  end

  def self.get_stripe_time_now
    Time.now.to_i
  end

  def self.price_type_to_checkout_session_mode(type)
    case type
    when ONE_TIME
      PAYMENT
    when RECURRING
      SUBSCRIPTION
    else
      ERROR
    end
  end
end
