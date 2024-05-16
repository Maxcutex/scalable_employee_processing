class HeaderMapping < ApplicationRecord
  belongs_to :employer

  validates :key, :value, presence: true
end
