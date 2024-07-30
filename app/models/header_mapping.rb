# frozen_string_literal: true

class HeaderMapping < ApplicationRecord
  belongs_to :employer

  validates :key, :value, presence: true
end
