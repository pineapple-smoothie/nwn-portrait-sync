class Conversion < ApplicationRecord
  belongs_to :user
  has_one_attached :image do |attachable|
    # Create TGA variants for each portrait size with padding
    attachable.variant :tga_huge,
      resize_to_fill: [ 256, 400 ],
      gravity: "north",
      extent: "256x512",
      background: "black",
      flatten: true,
      alpha: "off",
      format: :tga,
      orient: "bottom-left",
      flip: true,
      define: "tga:alpha-type=0 tga:image-type=2 tga:origin=bottom-left"

    attachable.variant :tga_large,
      resize_to_fill: [ 128, 200 ],
      gravity: "north",
      extent: "128x256",
      background: "black",
      flatten: true,
      alpha: "off",
      format: :tga,
      orient: "bottom-left",
      flip: true,
      define: "tga:alpha-type=0 tga:image-type=2 tga:origin=bottom-left"

    attachable.variant :tga_medium,
      resize_to_fill: [ 64, 100 ],
      gravity: "north",
      extent: "64x128",
      background: "black",
      flatten: true,
      alpha: "off",
      format: :tga,
      orient: "bottom-left",
      flip: true,
      define: "tga:alpha-type=0 tga:image-type=2 tga:origin=bottom-left"

    attachable.variant :tga_small,
      resize_to_fill: [ 32, 50 ],
      gravity: "north",
      extent: "32x64",
      background: "black",
      flatten: true,
      alpha: "off",
      format: :tga,
      orient: "bottom-left",
      flip: true,
      define: "tga:alpha-type=0 tga:image-type=2 tga:origin=bottom-left"

    attachable.variant :tga_tiny,
      resize_to_fill: [ 16, 25 ],
      gravity: "north",
      extent: "16x32",
      background: "black",
      flatten: true,
      alpha: "off",
      format: :tga,
      orient: "bottom-left",
      flip: true,
      define: "tga:alpha-type=0 tga:image-type=2 tga:origin=bottom-left"
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
