require 'securerandom'

famous_names = [
  "Peter Parker", "Tony Stark", "Steve Rogers", "Bruce Wayne", 
  "Clark Kent", "Diana Prince", "Natasha Romanoff", "Bruce Banner", 
  "Wanda Maximoff", "Stephen Strange"
]

n = 0
100.times do
  # Randomly select a name from the famous_names array
  name = famous_names.sample
  first_name, last_name = name.split

  # Append a random number to ensure uniqueness
  unique_username = "#{first_name.downcase}_#{last_name.downcase}_#{rand(1000..9999)}"

  User.create!(
    email: Faker::Internet.unique.email,
    username: unique_username,
    password: 'password',  # Dummy password
    password_confirmation: 'password',
    jti: SecureRandom.uuid
  )
  n += 1
  puts "#{n} - #{unique_username} created!"  # Output with unique username
end

puts "100 unique famous users created!"
