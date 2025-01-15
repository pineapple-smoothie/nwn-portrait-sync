# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

user1 = User.find_or_initialize_by(email_address: 'user1@example.com')
user1.password = 'password'
user1.password_confirmation = 'password'
user1.save!

user2 = User.find_or_initialize_by(email_address: 'user2@example.com')
user2.password = 'password'
user2.password_confirmation = 'password'
user2.save!
