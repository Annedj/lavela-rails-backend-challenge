module Providers
  class AvailabilitiesController < ApplicationController
    # GET /providers/:provider_id/availabilities
    # Expected params: from, to (ISO8601 timestamps)
    def index
      begin
        validate_iso8601_format(params)

        from = Time.zone.parse(params[:from])
        to = Time.zone.parse(params[:to])

        availabilities = Availability.where(
          provider_id: params[:provider_id],
          start_day_of_week: from.wday..to.wday,
          starts_at_time: from.strftime("%H:%M")..to.strftime("%H:%M")
        )
        render json: availabilities, status: :ok
      rescue ArgumentError => e
        render json: { error: "Argument error: #{e.message}" }, status: :bad_request
      end
    end

    private

    def validate_iso8601_format(params)
      raise ArgumentError, "Missing date parameters" if params[:from].blank? || params[:to].blank?

      # ISO8601 regex pattern
      iso8601_pattern = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(Z|[+-]\d{2}:\d{2})$/
      raise ArgumentError, "Invalid date format" unless params[:from].match?(iso8601_pattern) && params[:to].match?(iso8601_pattern)
    end
  end
end
