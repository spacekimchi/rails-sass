module Admin
  module Stripe
    class ProductsController < ApplicationController
      def index
        @products = ::Stripe::Product.list({active: true})
      end

      def show
        @product = ::Stripe::Product.retrieve(id: params[:id])
      end

      def create
        @product = Product.find_by(id: params[:product_id])
        if @product&.create_stripe_product
          redirect_to admin_product_path(@product), notice: 'Stripe product was created'
        elsif @product.present?
          redirect_to admin_products_path(@product), notice: 'Failed to create Stripe Product'
        else
          redirect_to admin_products_path, notice: 'Failed to find product'
        end
      end

      def update
        # TODO: Add updating actions
        redirect_to admin_products_path, notice: 'Action currently disabled'
        return
        @product = Product.find_by(id: params[:product_id])
        if @product
          redirect_to admin_product_path(@product), notice: 'Stripe product was updated'
        else
          redirect_to admin_products_path, notice: 'Stripe product was updated'
        end
      end
    end
  end
end
