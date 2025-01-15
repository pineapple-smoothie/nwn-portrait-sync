class Character < ApplicationRecord
  belongs_to :user

  has_one_attached :portrait do |attachable|
    attachable.variant :thumbnail, resize_to_limit: [ 256, 256 ], format: "png"

    # Resize and pad variants
    attachable.variant :h, resize_to_limit: [ 256, 400 ],
                          extent: "256x512",
                          gravity: "North",
                          background: "rgba(0,0,0,0)",
                          rotate: 180,
                          format: "tga"

    attachable.variant :l, resize_to_limit: [ 128, 200 ],
                          extent: "128x256",
                          gravity: "North",
                          background: "rgba(0,0,0,0)",
                          rotate: 180,
                          format: "tga"

    attachable.variant :m, resize_to_limit: [ 64, 100 ],
                          extent: "64x128",
                          gravity: "North",
                          background: "rgba(0,0,0,0)",
                          rotate: 180,
                          format: "tga"

    attachable.variant :s, resize_to_limit: [ 32, 50 ],
                          extent: "32x64",
                          gravity: "North",
                          background: "rgba(0,0,0,0)",
                          rotate: 180,
                          format: "tga"

    attachable.variant :t, resize_to_limit: [ 16, 25 ],
                          extent: "16x32",
                          gravity: "North",
                          background: "rgba(0,0,0,0)",
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
