require 'rails_helper'

RSpec.describe CheckoutsController, type: :controller do
  before do
    stub_request(:post, "https://api.stripe.com/v1/customers").
      to_return(status: 200, body: {
        id: "cus_123456789",  # Example customer ID
        object: "customer",
        email: "customer@example.com",
        metadata: { user_id: "1" }  # Make sure to return any metadata you are sending
      }.to_json, headers: {})
    allow(Stripe::Checkout::Session).to receive(:create).and_return(double('session', id: 'cs_test'))
  end

  describe 'GET #new' do
    let(:user) { create(:user) }
    let(:product) { create(:product) }  # Assumes you have a product factory
    let(:product_price) { create(:product_price, product: product) }

    before do
      sign_in_as user  # Adjust based on your authentication setup
    end

    context 'when the user is already subscribed to the product' do
      before do
        allow(user).to receive(:is_subscribed_to_product?).with(product).and_return(true)
      end

      it 'redirects to the product price page with a notice' do
        get :new, params: { product_price_id: product_price.id }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("You are already subscribed to #{product.name}")
      end
    end

    context 'when the user is not subscribed to the product' do
      before do
        allow(user).to receive(:is_subscribed_to_product?).and_return(false)
        allow(Stripe::Checkout::Session).to receive(:create).and_return(double('StripeSession', id: 'cs_test', url: 'http://example.com'))
      end

      it 'creates a new stripe checkout session' do
        get :new, params: { product_price_id: product_price.id }
        expect(Stripe::Checkout::Session).to have_received(:create)
      end
    end
  end

  describe 'GET #show' do
    let(:user) { create(:user) }

    before do
      sign_in_as user
    end

    it 'redirects on Stripe::InvalidRequestError' do
      allow(Stripe::Checkout::Session).to receive(:retrieve).and_raise(Stripe::InvalidRequestError.new("Invalid request", "param"))
      get :show, params: { id: 'invalid_id' }
      expect(response).to redirect_to(products_url)
      expect(flash[:notice]).to match(/something went wrong with processing your payment/)
    end
  end
end
