class SessionsController < Clearance::SessionsController
  def create

    super
    Rails.logger.debug "User ID in session after sign-in: #{session[:user_id]}"

  end

  def destroy
    super
  end
end
