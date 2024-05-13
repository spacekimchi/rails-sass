module Admin
  module Stripe
    class PricesController < ApplicationController
      def index
        @prices = ::Stripe::Price.list({active: true})
      end

      def show
        @product = ::Stripe::Price.retrieve(id: params[:id])
      end

      def create
        @product = Product.find_by(id: params[:product_id])
        @product_price = @product.product_prices.find_by(id: params[:product_price_id])
        if @product_price&.create_stripe_price
          redirect_to admin_product_product_price_path(@product, @product_price), notice: 'Stripe price was created'
        elsif @product_price.present?
          redirect_to admin_product_product_price_path(@product, @product_price), notice: 'Failed to create Stripe Price'
        else
          redirect_to admin_product_product_prices_path, notice: 'Failed to find product'
        end
      end

      def update
        # TODO: Add updating actions
        redirect_to admin_product_product_prices_path, notice: 'Action currently disabled'
        return
      end
    end
  end
end
