require 'rails_helper'

RSpec.describe UserSubscription, type: :model do
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

  describe "validations" do
    it "is valid with valid attributes" do
      user_subscription = build(:user_subscription)
      expect(user_subscription).to be_valid
    end
  end

  describe "#is_active?" do
    context "when the subscription is within the active period" do
      let(:user_subscription) { create(:user_subscription, current_period_end: 1.month.from_now.to_i) }

      it "returns true" do
        expect(user_subscription.is_active?).to be true
      end
    end

    context "when the subscription is past the active period" do
      let(:user_subscription) { create(:user_subscription, current_period_end: 1.day.ago.to_i) }

      it "returns false" do
        expect(user_subscription.is_active?).to be false
      end
    end
  end
end
