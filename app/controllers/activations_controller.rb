class ActivationsController < ApplicationController
  def edit
    user = User.find_by(activation_token: params[:activation_token])

    if user && !user.activated?
      user.activate
      sign_in user
      redirect_to root_url, notice: "Your account has been activated successfully!"
    else
      redirect_to sign_in_path, alert: "Invalid or expired activation link!"
    end
  end
end

