class UsersController < Clearance::UsersController
  def create
    super
    if @user.persisted?
      UserMailer.send_verification_email(@user).deliver_later
    else
      # If there are errors (handled by Clearance's create method), render the new template
    end
  end

  def user_from_params
    email = user_params.delete(:email)
    username = user_params.delete(:username)
    password = user_params.delete(:password)

    Clearance.configuration.user_model.new(user_params).tap do |user|
      user.email = email
      user.username = username
      user.password = password
    end
  end
end
