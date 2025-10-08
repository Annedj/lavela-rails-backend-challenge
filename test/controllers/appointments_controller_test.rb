require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  test "POST /appointments creates an appointment" do
    provider = create(:provider)
    create(:availability, :wednesday, provider: provider)
    client = create(:client)

    post "/appointments", params: { appointment: { client_id: client.id, provider_id: provider.id, starts_at: "2025-01-01T09:00:00Z", ends_at: "2025-01-01T10:00:00Z" } }

    assert_response :success
    assert_equal Appointment.count, 1
    assert_equal Appointment.first.client_id, client.id
  end

  test "POST /appointments does not create an appointment if there is no availability" do
    provider = create(:provider)
    create(:availability, :monday, provider: provider)
    client = create(:client)

    post "/appointments", params: { appointment: { client_id: client.id, provider_id: provider.id, starts_at: "2025-01-01T09:00:00Z", ends_at: "2025-01-01T10:00:00Z" } }

    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_equal Appointment.count, 0
    assert_includes json_response["error"], "Availability must exist"
  end

  test "DELETE /appointments/:id cancels an appointment" do
    provider = create(:provider)
    availability = create(:availability, provider: provider)
    client = create(:client)
    appointment = create(:appointment, client: client, provider: provider)

    delete "/appointments/#{appointment.id}"

    assert_response :success
    assert_equal Appointment.count, 1
    assert_equal Appointment.first.status, "canceled"
    assert_equal Appointment.first.canceled_at.to_i, Time.zone.now.to_i
  end
end
