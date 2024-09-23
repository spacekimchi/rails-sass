class UserMailer < ApplicationMailer
  default from: 'jin@jinz.co'

  def send_verification_email(user)
    @user = user
    return if @user.verified?
    @user.generate_verification_token
    @url  = edit_verification_url(@user.verification_token)
    mail(to: @user.email, subject: 'Account Verification')
  end
end
