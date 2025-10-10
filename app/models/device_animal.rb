class DeviceAnimal < ApplicationRecord
  belongs_to :device
  belongs_to :animal
  has_many :alerts, dependent: :destroy

  scope :covering, ->(date) {
    where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", date, date)
  }
end
