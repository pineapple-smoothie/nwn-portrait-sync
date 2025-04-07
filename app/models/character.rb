# == Schema Information
#
# Table name: characters
#
#  id         :integer          not null, primary key
#  filename   :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  server_id  :integer          not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_characters_on_filename   (filename) UNIQUE
#  index_characters_on_server_id  (server_id)
#  index_characters_on_user_id    (user_id)
#
# Foreign Keys
#
#  server_id  (server_id => servers.id)
#  user_id    (user_id => users.id)
#
class Character < ApplicationRecord
  MAX_FILENAME_LENGTH = 64

  belongs_to :user
  has_many :portraits, dependent: :destroy
  belongs_to :server

  accepts_nested_attributes_for :portraits, allow_destroy: true

  before_validation :generate_filename, on: :create

  validates :name, presence: true, uniqueness: { scope: :server_id, message: "has already been taken on this server" }
  validates :filename, presence: true, uniqueness: true, length: { maximum: MAX_FILENAME_LENGTH }

  private

  def generate_filename
    return if self.filename.present?

    self.filename = SecureRandom.alphanumeric(MAX_FILENAME_LENGTH)
  end
end
