# frozen_string_literal: true

require 'csv'

# CsvImportService is responsible for importing earnings data from a CSV file.
# It parses the CSV data, validates headers, and enqueues batches of rows to be processed by CsvImportWorker.
class CsvImportService
  BATCH_SIZE = 1000

  # Initializes the service with the employer and CSV data.
  #
  # @param employer [Employer] the employer for which the data is being imported
  # @param csv_data [String] the raw CSV data as a string
  def initialize(employer, csv_data)
    @employer = employer
    @csv_data = csv_data
    @layout = load_header_mappings
  end

  # Imports the CSV data by validating headers and enqueuing rows for processing.
  #
  # @raise [CSV::MalformedCSVError] if the CSV data is malformed
  # @raise [RuntimeError] if required headers are missing
  def import
    validate_headers
    CSV.parse(@csv_data, headers: true).each_slice(BATCH_SIZE) do |batch|
      CsvImportWorker.perform_async(@employer.id, batch.map(&:to_h))
    end
  rescue CSV::MalformedCSVError => e
    Rails.logger.error("CSV Import Error: Malformed CSV - #{e.class}: #{e.message}")
    raise e
  rescue StandardError => e
    Rails.logger.error("CSV Import Error: #{e.class}: #{e.message}")
    raise e
  end

  private

  # Loads the header mappings for the employer from the database.
  #
  # @return [Hash] a hash mapping CSV headers to database columns
  def load_header_mappings
    @employer.header_mappings.each_with_object({}) do |mapping, hash|
      hash[mapping.key] = mapping.value
    end
  end

  # Validates that the CSV data contains all required headers.
  #
  # @raise [RuntimeError] if any required headers are missing
  def validate_headers
    required_headers = @layout.values
    csv_headers = CSV.parse(@csv_data, headers: true).headers

    missing_headers = required_headers - csv_headers
    return if missing_headers.empty?

    Rails.logger.error("CSV Import Error: Missing required headers: #{missing_headers.join(', ')}")
    raise "Missing required headers: #{missing_headers.join(', ')}"
  end
end
