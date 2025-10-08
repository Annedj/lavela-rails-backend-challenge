class Provider < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  encrypts :name
  encrypts :email, deterministic: true

  has_many :appointments
  has_many :availabilities
end
