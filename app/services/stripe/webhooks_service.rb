module Stripe
  class WebhooksService
    # This is for handling events from the Stripe webhooks events
    # NOTES: We are not handling any invoice or payment_intent webhooks here because all of that info is already available to the customers
    #        on Stripe's hosted billing portal.
    #   params:
    #     event: Stripe::Event object
    def self.process_event(event)
      # TODO: Look into whether or not we want to handle other events
      case event.type
      when 'customer.created'
        handle_customer_created(event)
      when 'customer.subscription.updated', 'customer.subscription.deleted'
        handle_customer_subscription_updated(event)
      when 'price.created'
        handle_price_created(event)
      when 'checkout.session.completed'
        handle_checkout_session_completed(event)
      else
        puts "Unhandled event type: #{event.type}"
      end
    end

    def self.handle_customer_created(event)
      customer = event.data.object
      metadata = customer.metadata
      user = User.find(metadata.user_id)
      user.update(stripe_customer_id: customer.id)
    rescue => e
      message = "Error occured: #{e.message}"
      err = StripeWebhookError.create!(event_object: event.data.object, event_type: event.type, message: message)
      puts err
    end

    # We expand the invoice, payment_intent, and subscription for order processing
    # one_time payment products will not have invoices
    # We also want to grab the Charge object to retrieve the receipt
    # We are using the Pay gem to handle webhooks
    #   params:
    #     event: Stripe::Event object
    def self.handle_checkout_session_completed(event)
      session = event.data.object
      user = User.find(session.metadata.user_id)
      product = ::Product.find(session.metadata.product_id)
      product_price = product.product_prices.find(session.metadata.product_price_id)
      # If stripe_subscription is nil, then it is a one_time payment type
      stripe_subscription = session.subscription
      # If session.subscription was present, it was a recurring purchase and we handle it inside the customer.subscription.updated instead
      # We only want to create subscriptions here if it's for_subscription and is a one_time payment (lifetime subscriptions)
      if stripe_subscription.nil? && session.metadata&.for_subscription
        user_subscription = user.user_subscriptions.create(
          product: product,
          product_price: product_price,
          status: UserSubscription::STATUSES[:ACTIVE],
          current_period_start: StripeService.get_stripe_time_now(),
          current_period_end: Time.at(10.years.from_now()).to_i
        )
      end
    rescue => e
      message = "Error occured: #{e.message}"
      err = StripeWebhookError.create!(event_object: event.data.object, event_type: event.type, message: message)
      puts err
    end

    def self.handle_customer_subscription_updated(event)
      event_subscription = event.data.object
      customer_id = event_subscription.customer
      metadata = event_subscription.metadata
      user = User.find_by(stripe_customer_id: customer_id)
      product = ::Product.find(metadata.product_id)
      product_price = product.product_prices.find(metadata.product_price_id)
      user_subscription = user.user_subscriptions.find_or_create_by(stripe_subscription_id: event_subscription.id, product: product, product_price: product_price)
      user_subscription.status = event_subscription.status
      user_subscription.current_period_start = event_subscription.current_period_start if user_subscription.current_period_start != event_subscription.current_period_start
      user_subscription.current_period_end = event_subscription.current_period_end if user_subscription.current_period_end != event_subscription.current_period_end
      user_subscription.save
    rescue => e
      message = "Error occured: #{e.message}"
      err = StripeWebhookError.create!(event_object: event.data.object, event_type: event.type, message: message)
      puts err
    end

    def self.handle_price_created(event)
      event_price = event.data.object
      product_id = event_price.product
      product_price_id = event_price.metadata.product_price_id
      product_price = ProductPrice.find(product_price_id)
      product_price.update(stripe_price_id: event_price.id)
    rescue => e
      message = "Error occured: #{e.message}"
      err = StripeWebhookError.create!(event_object: event.data.object, event_type: event.type, message: message)
      puts err
    end
  end
end
