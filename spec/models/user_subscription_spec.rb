# == Schema Information
#
# Table name: user_subscriptions
#
#  id                     :bigint           not null, primary key
#  user_id                :bigint           not null
#  product_id             :bigint
#  product_price_id       :bigint
#  stripe_subscription_id :string(128)
#  status                 :string
#  current_period_start   :bigint
#  current_period_end     :bigint
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
require 'rails_helper'

RSpec.describe UserSubscription, type: :model do
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
