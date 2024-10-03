# == Schema Information
#
# Table name: users
#
#  id                    :bigint           not null, primary key
#  created_at   
#  updated_at            :datetime         not null
#  username              :string           not null
#  email                 :string           not null
#  encrypted_password    :string(128)      not null
#  confirmation_token    :string(128)
#  remember_token        :string(128)      not null
#  stripe_customer_id    :string
#  verification_token    :string
#  verified_at           :datetime
#  verified_requested_at :datetime
#
require 'rails_helper'

RSpec.describe User, type: :model do
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

  describe 'associations' do
    it 'has many user_roles' do
      user = create(:user)
      user_role1 = create(:user_role, :with_admin, user: user)
      user_role2 = create(:user_role, :with_super_admin, user: user)

      expect(user.user_roles).to include(user_role1, user_role2)
    end

    it 'destroys user_roles when user is destroyed' do
      user = create(:user)
      create(:user_role, :with_admin, user: user)

      expect { user.destroy }.to change { UserRole.count }.by(-1)
    end

    it 'has many roles through user_roles' do
      user = create(:user)
      role = create(:role)
      create(:user_role, user: user, role: role)

      expect(user.roles).to include(role)
    end

    it 'has many user_subscriptions' do
      user = create(:user)
      user_subscription1 = create(:user_subscription, user: user)
      user_subscription2 = create(:user_subscription, :lifetime_subscription, user: user)

      expect(user.user_subscriptions).to include(user_subscription1, user_subscription2)
    end

    it 'destroys user_subscriptions when user is destroyed' do
      user = create(:user)
      create(:user_subscription, user: user)

      expect { user.destroy }.to change { UserSubscription.count }.by(-1)
    end
  end

  describe '.active_users' do
    let!(:active_user) { create(:user) }
    let!(:active_subscription) { create(:user_subscription, user: active_user, status: 'active') }

    it 'includes users with active subscriptions' do
      expect(User.active_users).to include(active_user)
    end

    it 'excludes users without active subscriptions' do
      inactive_user = create(:user)
      expect(User.active_users).not_to include(inactive_user)
    end
  end

  describe '#generate_verification_token' do
    let(:user) { create(:user) }

    it 'should set a verification_token' do
      expect(user.verification_token).to eq(nil)
      user.generate_verification_token
      expect(user.verification_token).not_to eq(nil)
    end
  end

  describe '#complete_verification' do
    let(:user) { create(:user) }

    it 'should updated the verfied_at time and create a stripe customer' do
      expect(user.verified_at).to eq(nil)
      expect(user).to receive(:create_stripe_customer)
      user.complete_verification
      expect(user.verified_at).not_to eq(nil)
    end
  end

  describe '#verified?' do
    let(:user) { create(:user) }

    context 'when verified' do
      before do
        user.complete_verification
      end

      it 'should return true' do
        expect(user.verified?).to eq(true)
      end
    end

    context 'when not verified' do
      it 'should return false' do
        expect(user.verified?).to eq(false)
      end
    end
  end

  describe '#create_stripe_customer' do
    let(:user) { create(:user, email: 'test@example.com') }

    context 'when stripe_customer_id is already present' do
      before do
        user.update(stripe_customer_id: 'existing_customer_id')
      end

      it 'does not create a new Stripe customer' do
        expect(Stripe::Customer).not_to receive(:create)
        user.create_stripe_customer
      end
    end

    context 'when stripe_customer_id is not present' do
      let(:stripe_customer) { double('Stripe::Customer', id: 'new_customer_id') }

      before do
        allow(Stripe::Customer).to receive(:create).and_return(stripe_customer)
      end

      it 'creates a new Stripe customer' do
        expect(Stripe::Customer).to receive(:create).with(
          email: user.email,
          metadata: { user_id: user.id }
        )
        user.create_stripe_customer
      end

      it 'updates the user with the new stripe_customer_id' do
        user.create_stripe_customer
        expect(user.reload.stripe_customer_id).not_to eq(nil)
      end
    end

    context 'when Stripe::InvalidRequestError occurs' do
      before do
        allow(Stripe::Customer).to receive(:create).and_raise(Stripe::InvalidRequestError.new('Invalid request', {}))
      end

      xit 'catches the error and logs it' do
        expect(Rails.logger).to receive(:error)
        user.create_stripe_customer
      end
    end

    context 'when Stripe::StripeError occurs' do
      before do
        allow(Stripe::Customer).to receive(:create).and_raise(Stripe::StripeError.new)
      end

      xit 'catches the error and logs it' do
        expect(Rails.logger).to receive(:error).with(/Another problem occurred, maybe unrelated to Stripe. error:/)
        user.create_stripe_customer
      end
    end
  end

  describe '#admin?' do
    let(:user) { create(:user) }
    let(:admin_role) { create(:role, name: 'admin') }
    let(:super_admin_role) { create(:role, name: 'super_admin') }

    it 'returns true if the user has an admin role' do
      user.roles << admin_role
      expect(user.admin?).to be true
    end

    it 'returns false if the user does not have an admin role' do
      expect(user.admin?).to be false
    end
  end

  describe '#super_admin?' do
    let(:user) { create(:user) }
    let(:super_admin_role) { create(:role, :super_admin) }

    it 'returns true if the user has a super_admin role' do
      user.roles << super_admin_role
      expect(user.super_admin?).to be true
    end

    it 'returns false if the user does not have a super_admin role' do
      expect(user.super_admin?).to be false
    end
  end

  describe '#make_admin' do
    let(:user) { create(:user) }

    context 'when the user is already an admin' do
      let!(:user_role) { create(:user_role, :with_admin, user: user) }
      it 'should not create a new user_role' do
        expect(UserRole.count).to eq(1)
        expect {
          user.make_admin
        }.not_to change { UserRole.count }
        expect(user.admin?).to eq(true)
      end
    end

    context 'when the user is not an admin' do
      let!(:admin_role) { create(:role, :admin) }

      it 'should create a new user_role with role admin' do
        expect(UserRole.count).to eq(0)
        expect(user.admin?).to eq(false)
        expect {
          user.make_admin
        }.to change { UserRole.count }.by(1)
        expect(user.admin?).to eq(true)
      end
    end
  end

  describe '#make_super_admin' do
    let!(:user) { create(:user) }

    context 'when the user is already an admin' do
      let!(:user_role) { create(:user_role, :with_super_admin, user: user) }
      it 'should not create a new user_role' do
        expect(UserRole.count).to eq(1)
        expect {
          user.make_super_admin
        }.not_to change { UserRole.count }
        expect(user.super_admin?).to eq(true)
      end
    end

    context 'when the user is not an admin' do
      let!(:super_admin_role) { create(:role, :super_admin) }

      it 'should create a new user_role with role admin' do
        expect(UserRole.count).to eq(0)
        expect(user.super_admin?).to eq(false)
        expect {
          user.make_super_admin
        }.to change { UserRole.count }.by(1)
        expect(user.super_admin?).to eq(true)
      end
    end
  end

  describe '#remove_admin' do
    let!(:user) { create(:user) }

    context 'when the user is an admin' do
      let!(:user_role) { create(:user_role, :with_admin, user: user) }
      it 'should remove the admin_role' do
        expect(user.admin?).to eq(true)
        user.remove_admin
        expect(user.admin?).to eq(false)
      end
    end

    context 'when the user is not an admin' do
      it 'should do nothing' do
        expect(user.admin?).to eq(false)
        user.remove_admin
        expect(user.admin?).to eq(false)
      end
    end
  end

  describe '#remove_super_admin' do
    let!(:user) { create(:user) }

    context 'when the user is a super_admin' do
      let!(:user_role) { create(:user_role, :with_super_admin, user: user) }

      it 'should remove the super_admin user_role' do
        expect(user.super_admin?).to eq(true)
        user.remove_super_admin
        expect(user.super_admin?).to eq(false)
      end
    end

    context 'when the user is not a super_admin' do
      it 'should not do anything' do
        expect(user.super_admin?).to eq(false)
        user.remove_super_admin
        expect(user.super_admin?).to eq(false)
      end
    end
  end

  describe '#toggle_admin' do
    context 'when user is an admin' do
      let!(:user) { create(:user, :with_admin) }
      it 'should remove user_role admin for that user' do
        expect(user.admin?).to be(true)
        expect {
          user.toggle_admin
        }.to change { user.admin? }.to(false)
      end
    end

    context 'when user is not an admin' do
      let!(:user) { create(:user) }
      let!(:admin_role) { create(:role, :admin) }
      it 'should make that user an admin' do
        expect(user.admin?).to be(false)
        expect {
          user.toggle_admin
        }.to change { user.admin? }.to(true)
      end
    end
  end

  describe '#toggle_super_admin' do
    context 'when user is a super_admin' do
      let!(:user) { create(:user, :with_super_admin) }

      it 'should remove the super_admin for the user' do
        expect(user.super_admin?).to be(true)
        expect {
          user.toggle_super_admin
        }.to change { user.super_admin? }.to(false)
      end
    end

    context 'when user is not a super_admin' do
      let!(:user) { create(:user) }
      let!(:super_admin_role) { create(:role, :super_admin) }

      it 'should remove the super_admin for the user' do
        expect(user.super_admin?).to be(false)
        expect {
          user.toggle_super_admin
        }.to change { user.super_admin? }.to(true)
      end
    end
  end

  describe '#is_subscribed_to_product?' do
    context 'when user has an active subscription' do
      let!(:user) { create(:user) }
      let!(:product) { create(:product, :for_subscription) }
      let!(:user_subscription) { create(:user_subscription, product: product, user: user) }

      it 'should be true when user has an active product subscription' do
        expect(user.is_subscribed_to_product?(product)).to eq(true)
      end
    end

    context 'when user does not have an active subscription' do
      let!(:user) { create(:user) }
      let!(:product) { create(:product, :for_subscription) }
      let!(:user_subscription) { create(:user_subscription, :canceled, product: product, user: user) }

      it 'should be false when user has an active product subscription' do
        expect(user.is_subscribed_to_product?(product)).to eq(false)
      end
    end
  end

  describe 'callbacks' do
  end
end
