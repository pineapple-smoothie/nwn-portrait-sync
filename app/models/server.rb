class Server < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  has_many :characters
end
