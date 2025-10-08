class Appointment < ApplicationRecord
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validates :status, presence: true
  validates :client_id, presence: true
  validates :provider_id, presence: true
  validate :starts_at_before_ends_at
  validate :does_not_overlap_with_existing_appointment

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
    if Appointment.scheduled.exists?(provider_id: provider_id, starts_at: starts_at..ends_at, ends_at: starts_at..ends_at)
      errors.add(:starts_at, "overlaps with an existing appointment for this provider")
    end
  end
end
