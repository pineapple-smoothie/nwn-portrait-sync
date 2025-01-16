class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :downloads, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true,
                          uniqueness: true,
                          format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :username, presence: true, uniqueness: true

  def confirmed?
    email_confirmed?
  end

  def self.authenticate_by(params)
    # Try to find user by email or username
    user = User.find_by("email_address = :login OR username = :login", login: params[:login])

    # Then authenticate with password
    user&.authenticate(params[:password])
  end
end
