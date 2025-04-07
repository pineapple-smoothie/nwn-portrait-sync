# == Schema Information
#
# Table name: conversions
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer          not null
#
# Indexes
#
#  index_conversions_on_user_id  (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require "test_helper"

class ConversionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
