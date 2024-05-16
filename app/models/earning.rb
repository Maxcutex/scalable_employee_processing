class Earning < ApplicationRecord
  belongs_to :employee

  validates :earning_date, :amount, presence: true
end
