require "test_helper"

class Providers::AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  test "GET /providers/:provider_id/availabilities returns availabilities" do
    provider = create(:provider)
    availability = create(:availability, :wednesday, provider: provider)
    availability_out_of_range = create(:availability, :wednesday, provider: provider, slug: "test-availability-out-of-range", starts_at_time: "17:00", ends_at_time: "18:00")

    get "/providers/#{provider.id}/availabilities?from=2025-01-01T00:00:00Z&to=2025-01-01T12:00:00Z"
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal json_response, [ availability.as_json ]
    assert_not_includes json_response, [ availability_out_of_range.as_json ]
  end
end
