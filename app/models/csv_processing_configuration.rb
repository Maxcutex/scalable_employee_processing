# frozen_string_literal: true

# app/models/csv_processing_configuration.rb
class CsvProcessingConfiguration < ApplicationRecord
  belongs_to :employer

  validates :date_format, presence: true
  validates :amount_format, presence: true
  validates :currency, presence: true
  validates :cron_schedule, presence: true
  validates :start_date, presence: true
end
