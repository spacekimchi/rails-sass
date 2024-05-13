class CheckoutsController < ApplicationController
  before_action :require_login

  def new
    product_price = ProductPrice.find_by(id: params[:product_price_id])
    product = product_price.product
    # We are redirecting if the user is already subscribed to an product
    # We don't want a user to have multiple subscriptions to the same product
    if product.present? && current_user.is_subscribed_to_product?(product)
      redirect_to root_path, notice: "You are already subscribed to #{product.name}"
      return
    end
    args = {
      customer: current_user.stripe_customer_id,
      ui_mode: 'embedded',
      line_products: [{
        price: product_price.stripe_price_id,
        quantity: 1,
      }],
      mode: product_price.mode,
      metadata: {
        product_id: product_price.product_id,
        product_price_id: product_price.id,
        user_id: current_user.id,
        for_subscription: product.for_subscription?
      },
      return_url: checkout_url + '?session_id={CHECKOUT_SESSION_ID}'
    }
    if product_price.lifetime?
      args = args.merge({
        payment_intent_data: {
          metadata: {
            product_id: product_price.product_id,
            product_price_id: product_price.id,
            user_id: current_user.id,
            for_subscription: product.for_subscription?,
            receipt_email: current_user.email
          }
        }
      })
    else
      args = args.merge({
        subscription_data: {
          metadata: {
            product_id: product_price.product_id,
            product_price_id: product_price.id,
            user_id: current_user.id,
            for_subscription: product.for_subscription?,
            receipt_email: current_user.email
          }
        }
      })
    end
    @session = Stripe::Checkout::Session.create(**args)
  end

  # This route is essentially the same thing as the stripe webhook event for checkout.session.completed
  def show
    # What do we do in this route
    Stripe::Checkout::Session.retrieve(params[:session_id])
  rescue Stripe::InvalidRequestError => e
    redirect_to products_url, notice: "Sorry, something went wrong with processing your payment: #{e.message}"
  end
end
