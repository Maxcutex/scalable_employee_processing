# frozen_string_literal: true

# CsvProcessingService is responsible for processing CSV data for a given employer.
# It handles parsing the CSV file, validating headers, processing rows in batches,
# and managing configuration settings such as date format and exchange rate.
#
# This service uses CsvImportWorker to process the rows in the background, allowing
# for efficient handling of large files by breaking them into manageable batches.
# It also includes error handling for issues related to CSV parsing and processing.
class CsvProcessingService
  def initialize(employer, csv_data)
    @employer = employer
    @csv_data = csv_data
    @config = CsvProcessingConfiguration.find_by(employer: employer)
    @header_mappings = employer.header_mappings
    @date_format = @config.date_format || '%m/%d/%Y'
  end

  def process_csv
    @csv_rows = CSV.parse(csv_data, headers: true)
    validate_headers
    process_in_batches
  rescue CSV::MalformedCSVError => e
    handle_error("Malformed CSV data: #{e.message}")
  rescue StandardError => e
    handle_error("CSV processing failed: #{e.message}")
  end

  private

  attr_reader :csv_rows, :csv_data, :config, :date_format,
              :exchange_rate, :header_mappings, :employer

  def map_headers(row)
    mapped_data = {}
    header_mappings.each do |mapping|
      mapped_data[mapping.key.to_sym] = row[mapping.value]
    end
    mapped_data
  end

  def process_in_batches
    csv_rows.each_slice(BATCH_SIZE) do |batch|
      CsvImportWorker.perform_async(
        employer.id, config.attributes, batch.map do |row|
                                          map_headers(row)
                                        end, date_format, exchange_rate, header_mappings
      )
    end
  end

  def exchange_rate
    @exchange_rate ||= 1.0
  end

  def validate_headers
    required_headers = header_mappings.map(&:value)
    csv_headers = CSV.parse(csv_data, headers: true).headers

    missing_headers = required_headers - csv_headers
    return if missing_headers.empty?

    Rails.logger.error("CSV Import Error: Missing required headers: #{missing_headers.join(', ')}")
    raise "Missing required headers: #{missing_headers.join(', ')}"
  end

  def handle_error(message)
    Rails.logger.error("CSV Processing Error: #{message}")
    raise StandardError, message
  end
end
