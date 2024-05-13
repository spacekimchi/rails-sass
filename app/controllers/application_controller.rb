class ApplicationController < ActionController::Base
  include Clearance::Controller

  helper_method :super_admin?

  def super_admin?
    current_user&.super_admin?
  end
end
