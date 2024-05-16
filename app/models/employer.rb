class Employer < ApplicationRecord
  has_many :employees, dependent: :destroy
  has_many :header_mappings, dependent: :destroy

  validates :name, presence: true
end
  