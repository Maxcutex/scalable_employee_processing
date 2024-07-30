# frozen_string_literal: true

# CsvImportWorker is a Sidekiq worker that processes batches of CSV rows to create earnings records.
# It parses the CSV data, finds or creates employees, and creates earnings records.
class CsvImportWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'default'

  # Processes a batch of CSV rows for a given employer.
  #
  # @param employer_id [Integer] the ID of the employer
  # @param rows [Array<Hash>] the batch of CSV rows to process
  # @param date_format [String, nil] the date format string
  # @param exchange_rate [Float] the exchange rate for converting amounts
  def perform(employer_id, rows, date_format, exchange_rate, header_mappings)
    CsvEmployeeImportService.new(employer_id, rows, date_format, exchange_rate, header_mappings).run
  end
end
