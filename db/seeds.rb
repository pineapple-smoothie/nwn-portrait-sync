puts "🌱 Seeding the database"

puts "🖥️ Seeding Servers"

Server.find_or_create_by!(name: "Arelith")

# Load environment-specific seeds
environment_seed_path = Rails.root.join("db", "seeds", "#{Rails.env}_seeds.rb")
load(environment_seed_path) if File.exist?(environment_seed_path)

puts "💚 Finished seeding the database"
