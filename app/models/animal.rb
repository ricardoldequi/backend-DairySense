class Animal < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :breed, optional: false
  has_many :device_animals
  has_many :devices, through: :device_animals
  has_many :readings
end
