# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  username           :string           not null
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  activation_token   :string           not null
#  stripe_customer_id :string
#  activated_at       :datetime
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
    let(:super_admin_role) { create(:role, name: 'super_admin') }

    it 'returns true if the user has a super_admin role' do
      user.roles << super_admin_role
      expect(user.super_admin?).to be true
    end

    it 'returns false if the user does not have a super_admin role' do
      expect(user.super_admin?).to be false
    end
  end

  describe 'callbacks' do
    it 'calls create_stripe_customer after create' do
      user = build(:user)
      expect(user).to receive(:create_stripe_customer)
      user.save
    end
  end
end
