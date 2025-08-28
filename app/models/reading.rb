class Reading < ApplicationRecord
  belongs_to :device
  belongs_to :animal
end
