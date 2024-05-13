class UserMailer < ApplicationMailer
  default from: 'jin@traderz.com'

  def activation_needed_email(user)
    @user = user
    @url  = edit_activation_url(@user.activation_token)
    mail(to: @user.email, subject: 'Account Activation')
  end
end
