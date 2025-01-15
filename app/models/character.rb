class Character < ApplicationRecord
  belongs_to :user

  has_one_attached :portrait do |attachable|
    attachable.variant :thumbnail, resize_to_fill: [ 256, 256 ], format: "png"

    # Resize and pad variants
    attachable.variant :h, resize_to_fill: [ 256, 400 ],
                          gravity: "North",
                          extent: "256x512",
                          rotate: 180,
                          format: "tga"

    attachable.variant :l, resize_to_fill: [ 128, 200 ],
                          gravity: "North",
                          extent: "128x256",
                          rotate: 180,
                          format: "tga"

    attachable.variant :m, resize_to_fill: [ 64, 100 ],
                          gravity: "North",
                          extent: "64x128",
                          rotate: 180,
                          format: "tga"

    attachable.variant :s, resize_to_fill: [ 32, 50 ],
                          gravity: "North",
                          extent: "32x64",
                          rotate: 180,
                          format: "tga"

    attachable.variant :t, resize_to_fill: [ 16, 25 ],
                          gravity: "North",
                          extent: "16x32",
                          rotate: 180,
                          format: "tga"
  end

  validates :portrait, attached: { required: true, content_type: [ "image/jpg", "image/jpeg" ] }

  after_commit :process_variants, on: [ :create, :update ]

  private

  def process_variants
    return unless portrait.attached?

    # Process each variant
    [ :h, :l, :m, :s, :t ].each do |size|
      portrait.variant(size).processed
    end
  end
end
