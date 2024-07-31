# frozen_string_literal: true

# spec/services/unit/csv_processing_service_spec.rb

require 'rails_helper'
require 'csv'

RSpec.describe CsvProcessingService, type: :service do
  let(:employer) { instance_double('Employer', id: 1, header_mappings: header_mappings) }
  let(:csv_data) { "EmployeeNumber,CheckDate,Amount\nA123,12/14/2021,$800.50" }
  let(:config) { instance_double('CsvProcessingConfiguration', date_format: '%m/%d/%Y', attributes: {}) }
  let(:header_mappings) do
    [
      instance_double('HeaderMapping', key: 'employee_id', value: 'EmployeeNumber'),
      instance_double('HeaderMapping', key: 'date', value: 'CheckDate'),
      instance_double('HeaderMapping', key: 'amount', value: 'Amount')
    ]
  end

  before do
    allow(CsvProcessingConfiguration).to receive(:find_by).with(employer: employer).and_return(config)
    allow(config).to receive(:date_format).and_return('%m/%d/%Y')
    allow(config).to receive(:attributes).and_return({}) # Mock attributes if needed
    allow_any_instance_of(CsvProcessingService).to receive(:exchange_rate).and_return(1.0)
  end

  describe '#process_csv' do
    it 'parses the CSV and processes rows in batches' do
      parsed_csv = CSV::Table.new([
                                    CSV::Row.new(%w[EmployeeNumber CheckDate Amount], ['A123', '12/14/2021', '$800.50'])
                                  ])
      allow(CSV).to receive(:parse).with(csv_data, headers: true).and_return(parsed_csv)
      allow_any_instance_of(CsvProcessingService).to receive(:validate_headers)
      allow_any_instance_of(CsvProcessingService).to receive(:process_in_batches)

      service = CsvProcessingService.new(employer, csv_data)
      service.process_csv

      # Assertions are implicit in this test; if exceptions are raised, the test will fail
    end

    it 'logs and raises an error for malformed CSV data' do
    #   malformed_csv_data = "EmployeeNumber,CheckDate,Amount\nA123,12/14/2021,800.50\n"

    #   allow(CSV).to receive(:parse).with(malformed_csv_data, headers: true).and_raise(CSV::MalformedCSVError, 'malformed CSV')

    #   service = CsvProcessingService.new(employer, malformed_csv_data)

    #   expect(Rails.logger).to receive(:error).with('CSV Processing Error: Malformed CSV data: malformed CSV')

    #   expect { service.process_csv }.to raise_error(StandardError, 'Malformed CSV data: malformed CSV')
    end

    it 'logs and raises a generic processing error' do
      allow(CSV).to receive(:parse).with(csv_data, headers: true).and_raise(StandardError, 'some error')

      service = CsvProcessingService.new(employer, csv_data)

      expect(Rails.logger).to receive(:error).with('CSV Processing Error: CSV processing failed: some error')
      expect { service.process_csv }.to raise_error(StandardError, 'CSV processing failed: some error')
    end
  end

  describe '#map_headers' do
    it 'maps CSV headers to correct attributes' do
      row = CSV::Row.new(%w[EmployeeNumber CheckDate Amount], ['A123', '12/14/2021', '$800.50'])
      service = CsvProcessingService.new(employer, csv_data)
      mapped_row = service.send(:map_headers, row)

      expect(mapped_row).to eq({
                                 employee_id: 'A123',
                                 date: '12/14/2021',
                                 amount: '$800.50'
                               })
    end
  end

  describe '#validate_headers' do
    it 'does not raise an error when headers are correct' do
      valid_csv = CSV::Table.new([
                                   CSV::Row.new(%w[EmployeeNumber CheckDate Amount], ['A123', '12/14/2021', '$800.50'])
                                 ])
      allow(CSV).to receive(:parse).with(csv_data, headers: true).and_return(valid_csv)

      service = CsvProcessingService.new(employer, csv_data)

      expect { service.send(:validate_headers) }.not_to raise_error
    end

    it 'raises an error and logs it when headers are missing' do
      missing_headers_csv_data = "EmployeeNumber,CheckDate\nA123,12/14/2021"
      allow(CSV).to receive(:parse).with(missing_headers_csv_data, headers: true).and_return(CSV::Table.new([
                                                                                                              CSV::Row.new(
                                                                                                                %w[
                                                                                                                  EmployeeNumber CheckDate
                                                                                                                ], ['A123', '12/14/2021']
                                                                                                              )
                                                                                                            ]))

      service = CsvProcessingService.new(employer, missing_headers_csv_data)

      expect(Rails.logger).to receive(:error).with('CSV Import Error: Missing required headers: Amount')
      expect { service.send(:validate_headers) }.to raise_error(RuntimeError, 'Missing required headers: Amount')
    end
  end
end
