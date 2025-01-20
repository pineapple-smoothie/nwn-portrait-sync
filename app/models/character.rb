class Character < ApplicationRecord
  belongs_to :user
  has_many :portraits, dependent: :destroy

  before_validation :generate_filename, on: :create
  after_commit :process_variants, on: [ :create, :update ]

  private

  def generate_filename
    return if self.filename.present?

    filename = self.name.parameterize(separator: "_")
    filename += "_#{self.id}_"
    self.filename = filename
  end
end
