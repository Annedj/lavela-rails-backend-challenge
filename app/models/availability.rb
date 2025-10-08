class Availability < ApplicationRecord
  belongs_to :provider

  validates :start_day_of_week, presence: true
  validates :end_day_of_week, presence: true
  validates :starts_at_time, presence: true
  validates :ends_at_time, presence: true
  validates :source, presence: true
  validates :slug, presence: true

  validate :start_time_before_end_time
  validate :start_day_of_week_before_end_day_of_week

  private

  def start_time_before_end_time
    return unless start_day_of_week && end_day_of_week && starts_at_time && ends_at_time

    if start_day_of_week == end_day_of_week && starts_at_time >= ends_at_time
      errors.add(:starts_at_time, "must be before end time on the same day")
    end
  end

  def start_day_of_week_before_end_day_of_week
    return unless start_day_of_week && end_day_of_week

    day_difference = (end_day_of_week - start_day_of_week) % 7
    if day_difference > 1
      errors.add(:end_day_of_week, "must be the same day or the next day after start day")
    end
  end
end
