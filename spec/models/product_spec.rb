# == Schema Information
#
# Table name: products
#
#  id                :bigint           not null, primary key
#  stripe_product_id :string(128)
#  name              :string(128)      not null
#  description       :string
#  for_subscription  :boolean          default(TRUE), not null
#  is_active         :boolean          default(TRUE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
require 'rails_helper'

RSpec.describe Product, type: :model do
  it "is valid with valid attributes" do
    product = build(:product)
    expect(product).to be_valid
  end

  describe "scopes" do
    before do
      @active_product = create(:product)
      @inactive_product = create(:product, :inactive)
    end

    it "returns active products" do
      expect(Product.active).to include(@active_product)
      expect(Product.active).not_to include(@inactive_product)
    end
  end

  describe "#generate_stripe_product_id" do
    it "generates a unique stripe product ID" do
      product = create(:product)
      expected_prefix = "product_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{product.id}"
      expect(product.generate_stripe_product_id).to start_with(expected_prefix)
    end
  end

  describe "#create_stripe_product" do
    let(:product) { create(:product, stripe_product_id: nil) }
    before do
      # Stub for create_stripe_customer after_create callback
      stub_request(:post, "https://api.stripe.com/v1/products").
        to_return(status: 200, body: {
          id: "prod_123456789",
          object: "product",
          metadata: { user_id: "1", product_id: "1" }
        }.to_json, headers: {})
    end

    it "creates a stripe product if stripe_product_id is nil" do
      allow(Stripe::Product).to receive(:create).and_return(Stripe::Product.new(id: 'some_id'))
      expect { product.create_stripe_product }.to change { product.stripe_product_id }.from(nil).to(product.generate_stripe_product_id)
      expect(Stripe::Product).to have_received(:create).once
    end
  end
  describe "#create_stripe_product" do
    let(:product) { build(:product, stripe_product_id: nil) }

    it "handles Stripe invalid request errors gracefully" do
      allow(Stripe::Product).to receive(:create).and_raise(Stripe::InvalidRequestError.new("Invalid request", "param"))
      expect { product.create_stripe_product }.to_not raise_error
    end
  end
end
