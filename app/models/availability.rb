class Availability < ApplicationRecord
  belongs_to :provider

  validates :start_day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :end_day_of_week, presence: true, inclusion: { in: 0..6 }
  validates :starts_at_time, presence: true
  validates :ends_at_time, presence: true
  validates :source, presence: true
  validates :slug, presence: true

  validate :start_time_before_end_time
  validate :start_day_of_week_before_end_day_of_week

  def self.within_range(from, to)
    return none if from.blank? || to.blank?

    from_wday = from.wday
    to_wday = to.wday
    from_time = from.strftime("%H:%M")
    to_time = to.strftime("%H:%M")

    # Same day case
    if from.to_date == to.to_date
      where(start_day_of_week: from.wday..to.wday, starts_at_time: from.strftime("%H:%M")..to.strftime("%H:%M"))
    end
  end

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
