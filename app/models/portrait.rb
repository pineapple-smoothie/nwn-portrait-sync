class Portrait < ApplicationRecord
  belongs_to :character

  has_one_attached :file do |attachable|
    # Create web-friendly variants for each portrait size
    attachable.variant :web_huge, resize_to_fill: [ 256, 512 ], format: :webp
    attachable.variant :web_large, resize_to_fill: [ 128, 256 ], format: :webp
    attachable.variant :web_medium, resize_to_fill: [ 64, 128 ], format: :webp
    attachable.variant :web_small, resize_to_fill: [ 32, 64 ], format: :webp
    attachable.variant :web_tiny, resize_to_fill: [ 16, 32 ], format: :webp
    attachable.variant :thumbnail, resize_to_fill: [ 256, 256 ], format: :webp
  end

  after_commit :process_variants, on: [ :create, :update ]

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
    required: false,
    content_type: [ "image/x-targa", "image/x-tga" ]
  }

  enum :size, [ :huge, :large, :medium, :small, :tiny ]

  def size_dimensions
    TYPES[size.to_sym]
  end

  def web_variant_name
    "web_#{size}".to_sym
  end

  def processed_image
    if file.attached?
      if file.blob.content_type == "image/x-tga"
        # For TGA files, we need to convert to PNG first
        png_key = "#{file.blob.key}_png"
        png_blob = ActiveStorage::Blob.find_by(key: png_key)

        unless png_blob
          # Create a temporary file with .tga extension
          temp_file = Tempfile.new([ "portrait", ".tga" ])
          temp_file.binmode
          temp_file.write(file.download)
          temp_file.rewind

          # Convert TGA to PNG
          tga_image = MiniMagick::Image.open(temp_file.path)
          tga_image.format "png"

          # Store the PNG version
          png_blob = ActiveStorage::Blob.create_and_upload!(
            io: StringIO.new(tga_image.to_blob),
            filename: "#{file.filename.base}.png",
            content_type: "image/png",
            key: png_key
          )

          # Clean up temp file
          temp_file.close
          temp_file.unlink
        end

        # Create variant from the PNG version
        variant = png_blob.variant(
          resize_to_fill: [ size_dimensions[:width], size_dimensions[:height] ],
          format: :webp
        ).processed

        Rails.application.routes.url_helpers.rails_blob_path(variant, only_path: true)
      else
        # For non-TGA files (shouldn't happen, but just in case)
        file.variant(web_variant_name).processed.url
      end
    else
      # Return the fallback image path
      ActionController::Base.helpers.asset_path("fallback.webp")
    end
  end

  def download_tga
    return nil unless file.attached?

    if file.blob.content_type == "image/x-tga"
      file
    else
      # If somehow the file isn't a TGA, convert it to TGA
      convert_to_tga
    end
  end

  private

  def process_variants
    return unless file.attached?

    # Trigger variant processing in the background
    processed_image if file.blob.content_type == "image/x-tga"
  end

  def convert_to_tga
    # Create a temporary file with the original extension
    temp_file = Tempfile.new([ "portrait", File.extname(file.filename.to_s) ])
    temp_file.binmode
    temp_file.write(file.download)
    temp_file.rewind

    # Process with MiniMagick
    img = MiniMagick::Image.open(temp_file.path)
    img.format "tga"

    # Create a new blob for the converted image
    converted_blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(img.to_blob),
      filename: "#{file.filename.base}.tga",
      content_type: "image/x-tga"
    )

    # Clean up
    temp_file.close
    temp_file.unlink

    # Return the blob
    converted_blob
  end
end
