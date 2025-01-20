class Portrait < ApplicationRecord
  belongs_to :character

  has_one_attached :file

  validates :file, attached: { required: true, content_type: [ "image/tga" ] }
end
