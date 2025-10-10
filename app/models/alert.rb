class Alert < ApplicationRecord
  belongs_to :device_animal

  validates :alert_type, presence: true
  validates :detected_at, presence: true

  # Permite filtrar alertas por animal (via device_animal)
  scope :for_animal, ->(animal_id) {
    joins(:device_animal).where(device_animals: { animal_id: animal_id })
  }
  # Retorna o ID do animal associado ao alerta
  def animal_id
    device_animal&.animal_id
  end
end
