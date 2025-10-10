class ActivityBaseline < ApplicationRecord
  belongs_to :animal

  validates :hour_of_day, inclusion: { in: 0..23 }
  validates :baseline_enmo, presence: true
  validates :mad_enmo, presence: true
end
