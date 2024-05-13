# spec/models/product_price_spec.rb
require 'rails_helper'

RSpec.describe ProductPrice, type: :model do
  it "is valid with valid attributes" do
    product_price = build(:product_price)
    expect(product_price).to be_valid
  end

  describe "scopes" do
    let!(:active_product_price) { create(:product_price) }
    let!(:inactive_product_price) { create(:product_price, :inactive) }

    it "returns active product prices" do
      expect(ProductPrice.active).to include(active_product_price)
      expect(ProductPrice.active).not_to include(inactive_product_price)
    end
  end
  describe "#calculate_recurring" do
    context "when the price interval is lifetime" do
      let(:lifetime_price) { create(:product_price, interval: 'lifetime') }

      it "returns nil" do
        expect(lifetime_price.calculate_recurring).to be_nil
      end
    end

    context "when the price interval is not lifetime" do
      let(:monthly_price) { create(:product_price, interval: 'month') }

      it "returns a recurring hash" do
        expected_recurring = {
          interval: 'month',
          interval_count: 1,
          trial_period_days: nil,
          usage_type: ProductPrice::RECURRING_USAGE_TYPE
        }
        expect(monthly_price.calculate_recurring).to eq(expected_recurring)
      end
    end
  end

  describe "#create_stripe_price" do
    let(:product_price) { create(:product_price, stripe_price_id: nil) }

    before do
      allow(Stripe::Price).to receive(:create).and_return(double("StripePrice", id: "stripe_id"))
      allow(product_price.product).to receive(:stripe_product_id).and_return("stripe_product_id")
    end

    it "creates a stripe price if stripe_price_id and product's stripe_product_id are present" do
      allow(Stripe::Price).to receive(:create).and_return(Stripe::Price.new(id: 'some_id'))
      product_price.create_stripe_price
      expect(Stripe::Price).to have_received(:create).once
    end
  end
  describe "#create_stripe_price" do
    let(:product_price) { create(:product_price, stripe_price_id: nil) }

    it "handles Stripe invalid request errors gracefully" do
      allow(Stripe::Price).to receive(:create).and_raise(Stripe::InvalidRequestError.new("Invalid request", "param"))
      expect { product_price.create_stripe_price }.to_not raise_error
    end
  end


end

