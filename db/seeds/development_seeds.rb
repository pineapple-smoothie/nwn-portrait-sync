return unless Rails.env.development?

puts "🌱 Seeding with development data"
puts "👤 Seeding Users"

User.find_or_create_by!(username: "user") do |user|
  user.password = "password"
  user.password_confirmation = "password"
end
