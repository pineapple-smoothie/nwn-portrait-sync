class Portrait < ApplicationRecord
  belongs_to :character

  has_one_attached :file do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [ 256, 256 ], format: "png"
  end

  TYPES = {
    huge: {
      name: "Huge",
      width: 256,
      height: 512
    },
    large: {
      name: "Large",
      width: 128,
      height: 256
    },
    medium: {
      name: "Medium",
      width: 64,
      height: 128
    },
    small: {
      name: "Small",
      width: 32,
      height: 64
    },
    tiny: {
      name: "Tiny",
      width: 16,
      height: 32
    }
  }.freeze

  validates :file, attached: {
    required: true,
    content_type: [ "image/x-targa", "image/x-tga" ]
  }

  enum :size, [ :huge, :large, :medium, :small, :tiny ]

  def size_dimensions
    TYPES[size.to_sym]
  end

  def processed_image
    return unless file.attached?

    # Check if the file is a TGA and convert it
    if file.blob.content_type == "image/x-tga"
      convert_tga_to_png
    else
      file.variant(resize_to_limit: [ size_dimensions[:width], size_dimensions[:height] ]).processed
    end
  end

  private

  def convert_tga_to_png
    # Download the TGA file
    tga_file = MiniMagick::Image.read(file.download)
    # Convert to PNG
    tga_file.format "png"
    # Create a new blob for the converted image
    converted_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(tga_file.to_blob),
      filename: "#{file.filename.base}.png",
      content_type: "image/png"
    )
    # Return the URL for the converted image
    Rails.application.routes.url_helpers.rails_blob_path(converted_blob, only_path: true)
  end
end
