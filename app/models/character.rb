class Character < ApplicationRecord
  belongs_to :user
  has_many :portraits, dependent: :destroy
  belongs_to :server

  accepts_nested_attributes_for :portraits, allow_destroy: true

  before_validation :generate_filename, on: :create

  validates :name, presence: true, uniqueness: { scope: :server_id }
  validates :filename, presence: true, uniqueness: true

  private

  def generate_filename
    return if self.filename.present?

    self.filename = SecureRandom.alphanumeric(12)
  end
end
