# Seed data is intentionally left blank.
# Candidates can add sample clients/providers/availabilities once their schema is in place.

# Since AvailabilitySync#call is designed to be idempotent, we can run it multiple times without worrying about duplicates. However it depends on the provider_id, so we need to reset the database between seed runs.

require "faker"

puts "Seeding clients..."
10.times { Client.create(name: Faker::Name.name, email: Faker::Internet.email) }

puts "Seeding providers and availabilities..."
3.times do
  provider = Provider.create(name: Faker::Name.name, email: Faker::Internet.email)

  puts "Syncing availabilities for provider #{provider.id}..."
  AvailabilitySync.new.call(provider_id: provider.id)
end

puts "Done."
