module Stripe
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      endpoint_secret = ENV['STRIPE_SIGNING_SECRET']
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
      # Handle the event
      Stripe::WebhooksService.process_event(event)
      head :ok
    rescue JSON::ParserError => e
      # Invalid payload
      puts "Error parsing payload: #{e.message}"
      head :bad_request
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      puts "Error verifying webhook signature: #{e.message}"
      head :bad_request
    end
  end
end
