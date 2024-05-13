require 'rails_helper'

RSpec.describe Stripe::WebhooksService, type: :service do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:product_price) { create(:product_price, product: product) }
  let(:stripe_price) { create(:stripe_price, product: product) }

  before do
    # Stub for create_stripe_customer after_create callback
    # Figure out a way to globally stub this,
    # or remove this from the create callback in users
    stub_request(:post, "https://api.stripe.com/v1/customers").
      to_return(status: 200, body: {
        id: "cus_123456789",  # Example customer ID
        object: "customer",
        email: "customer@example.com",
        metadata: { user_id: "1" }  # Make sure to return any metadata you are sending
      }.to_json, headers: {})
  end

  # Mocking a Stripe::Event object
  def stripe_event_mock(type, data_object)
    OpenStruct.new(
      type: type,
      data: OpenStruct.new(object: data_object)
    )
  end

  describe '.handle_customer_created' do
    let(:metadata) { OpenStruct.new(user_id: user.id) }
    let(:customer) { OpenStruct.new(id: 'cus_123', metadata: metadata) }
    let(:event) { stripe_event_mock('customer.created', customer) }

    it 'updates the user with the stripe_customer_id' do
      expect { described_class.handle_customer_created(event) }
        .to change { user.reload.stripe_customer_id }.from(nil).to('cus_123')
    end

    context 'when an exception occurs' do
      before do
        allow(User).to receive(:find).and_raise(StandardError, "Something went wrong")
      end

      it 'creates a StripeWebhookError record' do
        expect { described_class.handle_customer_created(event) }
          .to change(StripeWebhookError, :count).by(1)
      end
    end
  end

  describe '.handle_checkout_session_completed' do
    let(:metadata) { OpenStruct.new(user_id: user.id, product_id: product.id, product_price_id: product_price.id, for_subscription: true) }
    let(:session) { OpenStruct.new(metadata: metadata, subscription: nil, invoice: nil) }
    let(:event) { stripe_event_mock('checkout.session.completed', session) }

    it 'creates a user subscription if session indicates a one-time payment for a subscription' do
      expect(User.active_users).not_to include(user)

      expect { described_class.handle_checkout_session_completed(event) }
        .to change { UserSubscription.count }.by(1)
      expect(User.active_users).to include(user)

      subscription = UserSubscription.last
      expect(subscription.product).to eq(product)
      expect(subscription.product_price).to eq(product_price)
      expect(subscription.status).to eq(UserSubscription::STATUSES[:ACTIVE])
    end

    it 'does not create a user subscription if there is a subscription present' do
      session.subscription = Faker::Number.hexadecimal
      expect { described_class.handle_checkout_session_completed(event) }
        .to change { UserSubscription.count }.by(0)
    end

    context 'when an exception occurs' do
      before do
        allow(User).to receive(:find).and_raise(StandardError, "Something went wrong")
      end

      it 'creates a StripeWebhookError record' do
        expect { described_class.handle_checkout_session_completed(event) }
          .to change(StripeWebhookError, :count).by(1)
      end
    end
  end

  describe '.handle_price_created' do
    let(:product_price) { create(:product_price, stripe_price_id: nil) }
    let(:event_price) { OpenStruct.new(id: 'price_123', product: product.id, metadata: OpenStruct.new(product_price_id: product_price.id)) }
    let(:event) { stripe_event_mock('price.created', event_price) }

    it 'updates the product_price with the stripe_price_id' do
      expect { described_class.handle_price_created(event) }
        .to change { product_price.reload.stripe_price_id }.from(nil).to('price_123')
    end

    context 'when an exception occurs' do
      before do
        allow(ProductPrice).to receive(:find).and_raise(StandardError, "Something went wrong")
      end

      it 'creates a StripeWebhookError record' do
        expect { described_class.handle_price_created(event) }
          .to change(StripeWebhookError, :count).by(1)
      end
    end
  end

  describe '.handle_customer_subscription_updated' do
    let(:metadata) { OpenStruct.new(product_id: product.id, product_price_id: product_price.id) }
    let(:event_subscription) { OpenStruct.new(id: 'sub_123', customer: 'cus_123', metadata: metadata, status: UserSubscription::STATUSES[:ACTIVE], current_period_start: 1.day.ago.to_i, current_period_end: 1.month.from_now.to_i) }
    let(:event) { stripe_event_mock('customer.subscription.updated', event_subscription) }
    let!(:user) { create(:user, stripe_customer_id: 'cus_123') }

    it 'updates or creates a user subscription record' do
      expect(User.active_users).not_to include(user)
      expect { described_class.handle_customer_subscription_updated(event) }
        .to change { UserSubscription.count }.by(1)

      expect(User.active_users).to include(user)

      subscription = UserSubscription.last
      expect(subscription.stripe_subscription_id).to eq('sub_123')
      expect(subscription.product).to eq(product)
      expect(subscription.product_price).to eq(product_price)
      expect(subscription.status).to eq(UserSubscription::STATUSES[:ACTIVE])
    end

    it 'updates the subscription periods correctly' do
      create(:user_subscription, stripe_subscription_id: 'sub_123', user: user, product: product, product_price: product_price)
      described_class.handle_customer_subscription_updated(event)
      subscription = UserSubscription.last
      expect(subscription.current_period_start.to_i).to eq(event_subscription.current_period_start)
      expect(subscription.current_period_end.to_i).to eq(event_subscription.current_period_end)
    end

    it 'correctly disables a subscription if it comes back with cancelled' do
      expect(User.active_users).not_to include(user)
      expect { described_class.handle_customer_subscription_updated(event) }
        .to change { UserSubscription.count }.by(1)
      expect(User.active_users).to include(user)

      event_subscription.status = UserSubscription::STATUSES[:CANCELED]
      expect { described_class.handle_customer_subscription_updated(event) }
        .to change { UserSubscription.count }.by(0)
      expect(User.active_users).not_to include(user)
    end

    context 'when an exception occurs' do
      before do
        allow(User).to receive(:find_by).and_raise(StandardError, "Something went wrong")
      end

      it 'creates a StripeWebhookError record' do
        expect { described_class.handle_customer_subscription_updated(event) }
          .to change(StripeWebhookError, :count).by(1)
      end
    end
  end
end
