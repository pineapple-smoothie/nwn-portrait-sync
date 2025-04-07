# == Schema Information
#
# Table name: servers
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Server < ApplicationRecord
  validates :name, presence: true, uniqueness: true, length: { maximum: 255 }

  has_many :characters
end
