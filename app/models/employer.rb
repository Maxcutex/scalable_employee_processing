# frozen_string_literal: true

class Employer < ApplicationRecord
  has_one :csv_processing_configuration
  has_many :employees, dependent: :destroy
  has_many :header_mappings, dependent: :destroy

  validates :name, presence: true
end
