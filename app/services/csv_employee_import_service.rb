# frozen_string_literal: true

# CsvImportWorker is a Sidekiq worker that processes batches of CSV rows to create earnings records.
# It parses the CSV data, finds or creates employees, and creates earnings records.
class CsvEmployeeImportService
  class InvalidAmount < StandardError; end

  # Processes a batch of CSV rows for a given employer.
  #
  # @param employer_id [Integer] the ID of the employer
  # @param rows [Array<Hash>] the batch of CSV rows to process
  # @param date_format [String, nil] the date format string
  # @param exchange_rate [Float] the exchange rate for converting amounts
  def initialize(employer_id, rows, date_format, exchange_rate, header_mappings)
    @employer = Employer.find(employer_id)
    @rows = rows
    @date_format = date_format
    @exchange_rate = exchange_rate
    @header_mappings = header_mappings
  end

  def run
    rows.map do |row|
      process_row(row)
    end
  end

  private

  attr_reader :employer, :rows, :date_format, :exchange_rate, :header_mappings

  # Processes an individual row and creates an earning if valid.
  #
  # @param employer [Employer] the employer to which the row belongs
  # @param row [Hash] the CSV row data
  # @param header_mapping [Hash] the header mapping
  # @param date_format [String, nil] the date format string
  # @param exchange_rate [Float] the exchange rate
  # @return [Hash] result hash with :success or :error key
  def process_row(row)
    employee = find_employee(row[header_mappings['employee_id']])
    earning_date = parse_date(row[header_mappings['date']])
    amount = parse_amount(row[header_mappings['amount']])
    earning = find_or_initialize_earnings(employee.id, earning_date)

    earning.amount = amount
    earning.save!
    { success: true }
  rescue ActiveRecord::RecordNotFound
    error_message = "Employee not found for external_ref: #{row[header_mappings['employee_id']]}"
  rescue ActiveRecord::RecordInvalid
    error_message = earning.errors.full_messages.first
  rescue Date::Error
    error_message = "Invalid date format: #{row[header_mappings['date']]}"
  rescue InvalidAmount
    error_message = "Invalid Amount: #{row[header_mappings['amount']]}"
  ensure
    if error_message.present?
      Rails.logger.error("CSV Import Worker Error: #{error_message} for employee ID #{row[header_mappings['employee_id']]}")
      { error: error_message }
    end
  end

  def find_or_initialize_earnings(employee_id, earning_date)
    Earning.find_or_initialize_by(employee_id: employee_id, earning_date: earning_date)
  end

  # Finds or creates an employee based on the external reference ID.
  #
  # @param employer [Employer] the employer to which the employee belongs
  # @param external_ref [String] the external reference ID of the employee
  # @return [Employee] the found or created employee
  def find_employee(external_ref)
    employer.employees.find_by!(external_ref: external_ref)
  end

  # Parses a date string according to the specified date format.
  #
  # @param date_str [String] the date string to parse
  # @param date_format [String, nil] the date format string, if provided
  # @return [Date] the parsed date
  # @raise [RuntimeError] if the date string is invalid
  def parse_date(date_str)
    if date_format
      Date.strptime(date_str, date_format)
    else
      Date.parse(date_str)
    end
  end

  # Parses an amount string and converts it to a decimal.
  #
  # @param amount_str [String] the amount string to parse
  # @param exchange_rate [Float] the exchange rate for conversion
  # @return [BigDecimal] the parsed amount
  # @raise [RuntimeError] if the amount string is invalid
  def parse_amount(amount_str)
    amount_string_cleaned = amount_str.gsub(/[^0-9.]/, '')

    raise InvalidAmount, "Invalid amount format: #{amount_str}" if amount_string_cleaned.empty?

    amount_string_cleaned.to_f * exchange_rate
  end
end
