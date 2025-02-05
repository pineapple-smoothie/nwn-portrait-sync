class Portrait < ApplicationRecord
  belongs_to :character

  has_one_attached :file do |attachable|
    # Create web-friendly variants for each portrait size
    attachable.variant :web_huge, format: :webp
    attachable.variant :web_large, format: :webp
    attachable.variant :web_medium, format: :webp
    attachable.variant :web_small, format: :webp
    attachable.variant :web_tiny, format: :webp
  end

  enum :size, [ :huge, :large, :medium, :small, :tiny ]

  after_commit :process_variants, on: [ :create, :update ]

  validates :file, attached: false
  validates :file, content_type: { in: [ :tga ], spoofing_protection: false }
  # validates :file, dimension: {
  #   width: { min: ->(record) { record.type[:width] },   max: ->(record) { record.type[:width] } },
  #   height: { min: ->(record) { record.type[:height] }, max: ->(record) { record.type[:height] } }
  # }, if: :file_attached?

  TYPES = {
    huge: {
      name: "Huge",
      abbreviation: "H",
      fallback_image: "fallback_H.webp",
      width: 256,
      height: 512,
      display_width: 256,
      display_height: 400
    },
    large: {
      name: "Large",
      abbreviation: "L",
      fallback_image: "fallback_L.webp",
      width: 128,
      height: 256,
      display_width: 128,
      display_height: 200
    },
    medium: {
      name: "Medium",
      abbreviation: "M",
      fallback_image: "fallback_M.webp",
      width: 64,
      height: 128,
      display_width: 64,
      display_height: 100
    },
    small: {
      name: "Small",
      abbreviation: "S",
      fallback_image: "fallback_S.webp",
      width: 32,
      height: 64,
      display_width: 32,
      display_height: 50
    },
    tiny: {
      name: "Tiny",
      abbreviation: "T",
      fallback_image: "fallback_T.webp",
      width: 16,
      height: 32,
      display_width: 16,
      display_height: 25
    }
  }.freeze


  def type
    TYPES[size.to_sym]
  end

  def web_variant_name
    "web_#{size}".to_sym
  end

  def web_variant
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
          flip: true,
          resize_to_fill: [ type[:display_width], type[:display_height], { gravity: "north" } ],
          format: :webp
        ).processed

        Rails.application.routes.url_helpers.rails_blob_path(variant, only_path: true)
      else
        # For non-TGA files (shouldn't happen, but just in case)
        file.variant(web_variant_name).processed.url
      end
    else
      # Return the fallback image path
      ActionController::Base.helpers.asset_path(type[:fallback_image])
    end
  end

  private

  def file_attached?
    file.attached?
  end

  def process_variants
    return unless file.attached?

    # Trigger variant processing in the background
    web_variant if file.blob.content_type == "image/x-tga"
  end
end
