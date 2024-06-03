# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CsvImportService do
  let(:employer) { create(:employer) }
  let(:valid_csv_data) do
    "EmployeeNumber,CheckDate,Amount\n" \
    "A123,12/14/2021,$800.50\n" \
    "B456,12/21/2021,$740.00\n"
  end
  let(:invalid_csv_data) { "EmployeeNumber,CheckDate,Amount\n\"A123,12/14/2021,$800.50\nB456,12/21/2021,$740.00" }
  let(:missing_header_csv_data) { "EmployeeNumber,CheckDate\nA123,12/14/2021,$800.50\n" }

  before do
    create(:header_mapping, employer: employer, key: 'employee_id', value: 'EmployeeNumber')
    create(:header_mapping, employer: employer, key: 'date', value: 'CheckDate')
    create(:header_mapping, employer: employer, key: 'amount', value: 'Amount')
  end

  it 'queues the CsvImportWorker for valid CSV data' do
    service = CsvImportService.new(employer, valid_csv_data)
    expect { service.import }.to change(CsvImportWorker.jobs, :size).by(1)
  end

  it 'raises an error for malformed CSV data' do
    service = CsvImportService.new(employer, invalid_csv_data)
    expect { service.import }.to raise_error(CSV::MalformedCSVError)
  end

  it 'raises an error for missing required headers' do
    service = CsvImportService.new(employer, missing_header_csv_data)
    expect { service.import }.to raise_error(RuntimeError, /Missing required headers/)
  end
end
