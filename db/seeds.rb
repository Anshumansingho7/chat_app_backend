# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'faker'

n = 0
1500.times do
  User.create!(
    email: Faker::Internet.unique.email,
    username: Faker::Internet.unique.username,
    password: 'password', # Dummy password
    password_confirmation: 'password',
    jti: SecureRandom.uuid
  )
  n += 1
  puts "#{n}"  # String interpolation for proper output
end

puts "1500 users created!"
