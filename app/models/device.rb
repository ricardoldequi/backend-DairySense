class Device < ApplicationRecord
  has_many :readings

  before_validation :generate_api_key, on: :create

  private

  def generate_api_key
    self.api_key ||= SecureRandom.uuid
  end
end
