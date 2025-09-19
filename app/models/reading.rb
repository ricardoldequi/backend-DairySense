class Reading < ApplicationRecord
  belongs_to :device
  belongs_to :animal

  # Garante que created_at e updated_at sejam salvos em America/Sao_Paulo
  def write_attribute(attr_name, value)
    if ["created_at", "updated_at"].include?(attr_name.to_s) && value.present?
      super(attr_name, value.in_time_zone("America/Sao_Paulo"))
    else
      super
    end
  end
end
