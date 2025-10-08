require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  test "POST /appointments creates an appointment" do
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
    client = Client.create(name: "Test Client", email: "test@example.com")

    post "/appointments", params: { appointment: { client_id: client.id, provider_id: provider.id, starts_at: "2025-01-01T09:00:00Z", ends_at: "2025-01-01T10:00:00Z" } }

    assert_response :success
    assert_equal Appointment.count, 1
    assert_equal Appointment.first.client_id, client.id
  end

  test "POST /appointments does not create an appointment if there is no availability" do
    provider = Provider.create(name: "Test Provider", email: "test@example.com")
    availability = Availability.create!(
      provider_id: provider.id,
      start_day_of_week: 1,
      end_day_of_week: 1,
      starts_at_time: "10:00",
      ends_at_time: "12:00",
      source: "calendly",
      slug: "test-availability"
    )
    client = Client.create(name: "Test Client", email: "test@example.com")

    post "/appointments", params: { appointment: { client_id: client.id, provider_id: provider.id, starts_at: "2025-01-01T09:00:00Z", ends_at: "2025-01-01T10:00:00Z" } }

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_equal Appointment.count, 0
    assert_includes json_response["error"], "Availability must exist"
  end

  test "DELETE /appointments/:id cancels an appointment" do
    provider = Provider.create(name: "Test Provider", email: "test@example.com")
    availability = Availability.create!(
      provider_id: provider.id,
      start_day_of_week: 4,
      end_day_of_week: 4,
      starts_at_time: "09:00",
      ends_at_time: "10:00",
      source: "calendly",
      slug: "test-availability"
    )
    client = Client.create(name: "Test Client", email: "test@example.com")
    appointment = Appointment.create!(client_id: client.id, provider_id: provider.id, starts_at: "2025-01-02T09:00:00Z", ends_at: "2025-01-02T10:00:00Z")

    delete "/appointments/#{appointment.id}"

    assert_response :success
    assert_equal Appointment.count, 1
    assert_equal Appointment.first.status, "canceled"
    assert_equal Appointment.first.canceled_at.to_i, Time.zone.now.to_i
  end
end
