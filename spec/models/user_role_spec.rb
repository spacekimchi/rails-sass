require 'rails_helper'

RSpec.describe UserRole, type: :model do
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
      user = FactoryBot.build(:user)
      expect(user).to be_valid
    end

    it "is not valid without an email" do
      user = FactoryBot.build(:user, email: nil)
      expect(user).not_to be_valid
    end
  end
end
