class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create confirm ]
  rate_limit to: 5, within: 1.hour, only: :create, with: -> { redirect_to new_registration_path, alert: "Too many registration attempts. Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email_confirmed = false
    @user.confirmation_token = generate_token

    if @user.save
      RegistrationMailer.confirm(@user).deliver_later
      redirect_to new_session_path, notice: "Please check your email to confirm your account."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    @user = User.find_by_confirmation_token!(params[:token])
    @user.update!(email_confirmed: true, confirmation_token: nil)
    redirect_to new_session_path, notice: "Email confirmed! You can now sign in."
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_registration_path, alert: "Invalid or expired confirmation link."
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end

  def generate_token
    Rails.application.message_verifier(:confirmation).generate(
      { user_id: @user.id, email: @user.email_address },
      purpose: :confirm_email,
      expires_in: 2.days
    )
  end
end
