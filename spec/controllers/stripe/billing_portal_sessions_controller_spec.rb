require 'rails_helper'

RSpec.describe Stripe::BillingPortalSessionsController, type: :controller do
  before do
    # Stub for create_stripe_customer after_create callback
    stub_request(:post, "https://api.stripe.com/v1/customers").
      to_return(status: 200, body: {
        id: "cus_123456789",  # Example customer ID
        object: "customer",
        email: "customer@example.com",
        metadata: { user_id: "1" }  # Make sure to return any metadata you are sending
      }.to_json, headers: {})
  end

  describe "POST #create" do
    context "when user is logged in" do
      let(:user) { create(:user) }
      let(:mock_stripe_session) { double('StripeSession', url: Faker::Internet.url) }

      before do
        sign_in_as(user)
        allow(Stripe::BillingPortal::Session).to receive(:create).and_return(mock_stripe_session)
      end

      it "creates a Stripe billing portal session and redirects" do
        post :create
        expect(response).to redirect_to(mock_stripe_session.url)
      end
    end

    context "when no user is logged in" do
      it "redirects to the home page" do
        post :create
        expect(response).to redirect_to(sign_in_url)
      end
    end
  end
end
