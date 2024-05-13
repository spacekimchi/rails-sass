class ProductsController < ApplicationController
  def index
    @products = Product.active
    @user_subscriptions = current_user.user_subscriptions.active.pluck(:id) rescue []
  end

  def show
    @product = Product.active.find(params[:id])
    @product_prices = @product.product_prices.active
    @is_user_already_subscribed = current_user.is_subscribed_to_product?(@product)
  end
end
