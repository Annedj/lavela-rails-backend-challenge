require "test_helper"

class Providers::AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  test "GET /providers/:provider_id/availabilities returns availabilities" do
    provider = Provider.create(name: "Test Provider", email: "test@example.com")
    availability = Availability.create!(
      provider_id: provider.id,
      start_day_of_week: 3,
      end_day_of_week: 3,
      starts_at_time: "09:00",
      ends_at_time: "10:00",
      source: "calendly",
      slug: "test-availability"
    )
    availability_out_of_range = Availability.create!(provider_id: provider.id,
      start_day_of_week: 3,
      end_day_of_week: 3,
      starts_at_time: "017:00",
      ends_at_time: "18:00",
      source: "calendly",
      slug: "test-availability-out-of-range"
    )

    get "/providers/#{provider.id}/availabilities?from=2025-01-01T00:00:00Z&to=2025-01-01T12:00:00Z"
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal json_response, [ availability.as_json ]
    assert_not_includes json_response, [ availability_out_of_range.as_json ]
  end
end
