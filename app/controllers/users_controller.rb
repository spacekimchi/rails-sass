class UsersController < Clearance::UsersController
  def create
    super
    if @user.persisted?
      UserMailer.activation_needed_email(@user).deliver_later
    else
      # If there are errors (handled by Clearance's create method), render the new template
    end
  end
end
