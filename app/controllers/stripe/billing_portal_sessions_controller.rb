module Stripe
  class BillingPortalSessionsController < ApplicationController
    before_action :require_login

    def create
      stripe_billing_portal_session = Stripe::BillingPortal::Session.create({
        customer: current_user.stripe_customer_id,
        return_url: root_url
      })
      redirect_to stripe_billing_portal_session.url, allow_other_host: true
    end
  end
end
