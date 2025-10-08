class Appointment < ApplicationRecord
  belongs_to :client
  belongs_to :provider

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :status, presence: true
  validates :client_id, presence: true
  validates :provider_id, presence: true
  validate :starts_at_before_ends_at
  validate :does_not_overlap_with_existing_appointment
  validate :availability_exists

  enum :status, {
    scheduled: 0,
    canceled: 1
  }

  private

  def starts_at_before_ends_at
    if starts_at >= ends_at
      errors.add(:starts_at, "must be before end date and time")
    end
  end

  def does_not_overlap_with_existing_appointment
    if Appointment.scheduled.where.not(id: id).exists?(provider_id: provider_id, starts_at: starts_at..ends_at, ends_at: starts_at..ends_at)
      errors.add(:starts_at, "overlaps with an existing appointment for this provider")
    end
  end

  def availability_exists
    if Availability.find_by(provider_id: provider_id, start_day_of_week: starts_at.wday, end_day_of_week: ends_at.wday, starts_at_time: starts_at.strftime("%H:%M"), ends_at_time: ends_at.strftime("%H:%M")).nil?
      errors.add(:availability, "must exist")
    end
  end
end
