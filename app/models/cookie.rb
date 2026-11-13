class Cookie < ApplicationRecord
  validates :name, presence: true
  validates :ingredients, presence: true

  def self.ransackable_attributes(_auth_object = nil) = %w[name ingredients]
end
