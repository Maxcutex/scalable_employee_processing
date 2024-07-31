# frozen_string_literal: true

# app/models/csv_processing_configuration.rb
class CsvProcessingConfiguration < ApplicationRecord
  belongs_to :employer

  validates :date_format, :amount_format, :currency, :start_date, :cron_schedule, presence: true

end
