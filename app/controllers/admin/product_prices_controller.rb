module Admin
  class ProductPricesController < ApplicationController
    def index
      @product = Product.find(params[:product_id])
      @product_prices = @product.product_prices
    end

    def new
      @product = Product.find(params[:product_id])
      @product_price = @product.product_prices.build
    end

    def create
      @product = Product.find(params[:product_id])
      @product_price = @product.product_prices.build(product_price_params)
      if @product_price.save
        redirect_to admin_product_product_prices_path(@product), notice: 'Product price was successfully created.'
      else
        render :new
      end
    end

    def show
      @product = Product.find(params[:product_id])
      @product_price = ProductPrice.find(params[:id])
    end

    def edit
      @product = Product.find(params[:product_id])
      @product_price = ProductPrice.find(params[:id])
    end

    def update
      @product = Product.find(params[:product_id])
      @product_price = ProductPrice.find(params[:id])
      if @product_price.update(product_price_params)
        redirect_to admin_product_product_price_path(@product, @product_price), notice: 'Product price was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @product = Product.find(params[:product_id])
      @product_price = ProductPrice.find(params[:id])
      @product_price.destroy
      redirect_to admin_product_product_prices_path(@product), notice: 'Product price was successfully destroyed.'
    end

    private

    def product_price_params
      params.require(:product_price).permit(:name, :description, :is_active, :interval, :price, :lookup_key, :stripe_price_id, :type)
    end
  end
end
