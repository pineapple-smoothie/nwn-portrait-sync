class RegistrationMailer < ApplicationMailer
  layout "mailer"

  def confirm(user)
    @user = user
    mail subject: "Confirm your email address", to: user.email_address
  end
end
