module Admin
  class UsersController < ApplicationController
    def index
      @users = User.all.includes(:user_roles)
    end

    def show
      @user = User.find_by(id: params[:id])
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.save
        redirect_to admin_user_path(@user), notice: 'User was successfully created'
      else
        render :new
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      if @user.update(user_params)
        redirect_to [:admin, @user], notice: 'User was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy
      redirect_to users_url, notice: 'User was successfully destroyed.'
    end

    def toggle_admin
      @user = User.find(params[:id])
      @user.toggle_admin
      respond_to do |format|
        format.turbo_stream
      end
    end

    def toggle_super_admin
      @user = User.find(params[:id])
      @user.toggle_super_admin
      respond_to do |format|
        format.turbo_stream
      end
    end

    def send_verification_email
      @user = User.find(params[:id])
      UserMailer.send_verification_email(@user).deliver_later!
      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :username, :stripe_customer_id, :activated_at)
    end
  end
end
