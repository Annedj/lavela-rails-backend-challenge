class AvailabilitySync
  class ProviderNotFoundError < StandardError; end

  def initialize(client: CalendlyClient.new)
    @client = client
  end

  # Syncs availabilities for a provider based on the Calendly feed.
  # Candidates should fetch slots from the CalendlyClient and upsert Availability records.
  def call(provider_id:)
    slots = client.fetch_slots(provider_id)

    slots.each do |slot|
      provider = Provider.find_by(id: slot["provider_id"])

      raise ProviderNotFoundError, "Provider #{slot['provider_id']} not found" if provider.nil?

      availability = Availability.find_or_initialize_by(
        provider_id: slot["provider_id"],
        slug: slot["id"],
        source: slot["source"]
      )
      availability.assign_attributes(
        start_day_of_week: day_of_week_to_integer(slot["starts_at"]["day_of_week"]),
        end_day_of_week: day_of_week_to_integer(slot["ends_at"]["day_of_week"]),
        starts_at_time: slot["starts_at"]["time"],
        ends_at_time: slot["ends_at"]["time"],
      )
      availability.save!
      p availability if availability.errors.any?
    end

  rescue ProviderNotFoundError => e
    Rails.logger.error("Provider error during availability sync: #{e.message}")
    raise StandardError, "Failed to sync provider #{provider_id} availabilities: #{e.message}"
  end

  private

  attr_reader :client

  def day_of_week_to_integer(day_of_week)
    DateAndTime::Calculations::DAYS_INTO_WEEK[day_of_week.to_sym]
  end
end


# [{"id" => "p1-slot-early-morning",
#   "provider_id" => 1,
#   "starts_at" => {"day_of_week" => "monday", "time" => "06:30"},
#   "ends_at" => {"day_of_week" => "monday", "time" => "07:00"},
#   "source" => "calendly"},
#  {"id" => "p1-slot-morning-1",
#   "provider_id" => 1,
#   "starts_at" => {"day_of_week" => "monday", "time" => "09:00"},
#   "ends_at" => {"day_of_week" => "monday", "time" => "09:30"},
#   "source" => "calendly"},
