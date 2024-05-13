class HomeController < ApplicationController
  def index

    Rails.logger.debug "User ID in session after sign-in: #{session[:user_id]}"
  end
end
