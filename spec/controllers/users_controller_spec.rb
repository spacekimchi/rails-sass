require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before do
    # Stub for create_stripe_customer after_create callback
    stub_request(:post, "https://api.stripe.com/v1/customers").
      to_return(status: 200, body: {
        id: "cus_123456789",  # Example customer ID
        object: "customer",
        email: "customer@example.com"
      }.to_json, headers: {})
  end

  describe '#create' do
    let(:user_params) { { user: { email: Faker::Internet.email, username: Faker::Internet.username, password: Faker::Internet.password } } }

    it 'sends an activation email after creating a user' do
      allow(UserMailer).to receive(:send_verification_email).and_call_original

      expect {
        post :create, params: user_params
      }.to have_enqueued_job.exactly(:once).and have_enqueued_job(ActionMailer::MailDeliveryJob)

      expect(UserMailer).to have_received(:send_verification_email).with(User.find_by(email: user_params[:user][:email]))
    end

    it 'does not send an email if the user creation fails' do
      # Assuming validation fails if the email is nil
      expect {
        post :create, params: { user: { email: nil, password: 'password' } }
      }.to change { ActionMailer::Base.deliveries.size }.by(0)
    end
  end
end

