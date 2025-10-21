class Cookie < ApplicationRecord
  validates :name, presence: true
  validates :ingredients, presence: true
end
