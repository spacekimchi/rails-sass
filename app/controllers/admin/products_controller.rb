module Admin
  class ProductsController < ApplicationController
    def index
      @products = Product.all
    end

    def show
      @product = Product.find_by(id: params[:id])
    end

    def new
      @product = Product.new
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_product_path(@product), notice: 'Product was successfully created'
      else
        render :new
      end
    end

    def edit
      @product = Product.find(params[:id])
    end

    def update
      @product = Product.find(params[:id])
      if @product.update(product_params)
        redirect_to [:admin, @product], notice: 'Product was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @product = Product.find(params[:id])
      @product.destroy
      redirect_to products_url, notice: 'Product was successfully destroyed.'
    end

    private

    def product_params
      params.require(:product).permit(:name, :description, :stripe_product_id, :lookup_key, :is_active, :for_subscription)
    end
  end
end
