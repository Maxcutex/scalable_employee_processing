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
  def perform(employer_id, rows)
    employer = Employer.find(employer_id)
    layout = employer.header_mappings.each_with_object({}) do |mapping, hash|
      hash[mapping.key] = mapping.value
    end

    successful_count = 0
    failed_count = 0

    rows.each do |row|
      employee = find_employee(employer, row[layout['employee_id']])
      earning_date = parse_date(row[layout['date']], '%m/%d/%Y')
      amount = parse_amount(row[layout['amount']])

      create_earning(employee, earning_date, amount)
      successful_count += 1
    rescue StandardError => e
      Rails.logger.error("CSV Import Worker Error: #{e.message} for row #{row}")
      failed_count += 1
    end

    # Print out the success and failure counts
    puts "Batch Processing Results: #{successful_count} successful, #{failed_count} failed."

  end

  private

  # Finds or creates an employee based on the external reference ID.
  #
  # @param employer [Employer] the employer to which the employee belongs
  # @param external_ref [String] the external reference ID of the employee
  # @return [Employee] the found or created employee
  def find_employee(employer, external_ref)
    employer.employees.find_by!(external_ref: external_ref)
  rescue ActiveRecord::RecordNotFound
    raise "Employee not found for external_ref: #{external_ref}"
  end

  # Parses a date string according to the specified date format.
  #
  # @param date_str [String] the date string to parse
  # @param date_format [String, nil] the date format string, if provided
  # @return [Date] the parsed date
  # @raise [RuntimeError] if the date string is invalid
  def parse_date(date_str, date_format)
    if date_format
      Date.strptime(date_str, date_format)
    else
      Date.parse(date_str)
    end
  rescue ArgumentError, Date::Error
    raise "Invalid date format: #{date_str}"
  end

  # Parses an amount string and converts it to a decimal.
  #
  # @param amount_str [String] the amount string to parse
  # @return [BigDecimal] the parsed amount
  # @raise [RuntimeError] if the amount string is invalid
  def parse_amount(amount_str)
    cleaned_amount = amount_str.gsub(/[^0-9.]/, '')
    raise "Invalid amount format: #{amount_str}" unless cleaned_amount =~ /\A\d+(\.\d+)?\z/

    cleaned_amount.to_d
  end

  # Creates an earning record for an employee.
  #
  # @param employee [Employee] the employee for whom the earning is created
  # @param earning_date [Date] the date of the earning
  # @param amount [BigDecimal] the amount of the earning
  def create_earning(employee, earning_date, amount)
    employee.earnings.create!(earning_date: earning_date, amount: amount)
  rescue ActiveRecord::RecordInvalid => e
    raise "Earning creation failed: #{e.message} for employee #{employee.id} on #{earning_date} for amount #{amount}"
  end
end
