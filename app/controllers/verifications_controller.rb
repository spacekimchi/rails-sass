class VerificationsController < ApplicationController
  def edit
    user = User.find_by(verification_token: params[:verification_token])

    if user && !user.verified?
      user.complete_verification
      sign_in user
      redirect_to root_url, notice: "Your account has been verified successfully!"
    else
      redirect_to sign_in_path, alert: "Invalid or expired verification link!"
    end
  end
end

