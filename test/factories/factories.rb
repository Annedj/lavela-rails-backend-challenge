# test/factories/providers.rb
FactoryBot.define do
  factory :provider do
    name { "Test Provider" }
    email { "test@example.com" }
  end
end

# test/factories/availabilities.rb
FactoryBot.define do
  factory :availability do
    association :provider
    start_day_of_week { 4 }
    end_day_of_week { 4 }
    starts_at_time { "09:00" }
    ends_at_time { "10:00" }
    source { "calendly" }
    slug { "test-availability" }

    # You can define traits for different availability patterns
    trait :wednesday do
      start_day_of_week { 3 }
      end_day_of_week { 3 }
    end

    trait :friday do
      start_day_of_week { 5 }
      end_day_of_week { 5 }
    end

    trait :monday do
      start_day_of_week { 1 }
      end_day_of_week { 1 }
      starts_at_time { "10:00" }
      ends_at_time { "12:00" }
    end
  end
end

# test/factories/clients.rb
FactoryBot.define do
  factory :client do
    name { "Test Client" }
    email { "test@example.com" }
  end
end

# test/factories/appointments.rb
FactoryBot.define do
  factory :appointment do
    association :client
    association :provider
    starts_at { "2025-01-02T09:00:00Z" }
    ends_at { "2025-01-02T10:00:00Z" }
  end
end
