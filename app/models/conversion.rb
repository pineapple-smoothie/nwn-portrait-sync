class Conversion < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    # Create TGA variants for each portrait size
    attachable.variant :tga_huge, format: :tga, resize_to_fill: [ 256, 512 ], gravity: "north"
    attachable.variant :tga_large, format: :tga, resize_to_fill: [ 128, 256 ], gravity: "north"
    attachable.variant :tga_medium, format: :tga, resize_to_fill: [ 64, 128 ], gravity: "north"
    attachable.variant :tga_small, format: :tga, resize_to_fill: [ 32, 64 ], gravity: "north"
    attachable.variant :tga_tiny, format: :tga, resize_to_fill: [ 16, 32 ], gravity: "north"
  end

  validates :image, attached: true

  after_commit :process_variants, on: [ :create, :update ]

  private

  def process_variants
    return unless image.attached?

    image.variant(:tga_huge).processed
    image.variant(:tga_large).processed
    image.variant(:tga_medium).processed
    image.variant(:tga_small).processed
    image.variant(:tga_tiny).processed
  end
end
