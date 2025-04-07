# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  confirmation_token :string
#  email_confirmed    :boolean          default(FALSE)
#  password_digest    :string           not null
#  username           :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token  (confirmation_token) UNIQUE
#  index_users_on_username            (username) UNIQUE
#
class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :downloads, dependent: :destroy

  validates :username, presence: true, uniqueness: true
end
