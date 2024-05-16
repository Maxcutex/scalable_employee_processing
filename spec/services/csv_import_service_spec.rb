require 'rails_helper'

RSpec.describe CsvImportService do
  let(:employer) { create(:employer) }
  let(:csv_data) do
    "EmployeeNumber,CheckDate,Amount\n" \
    "A123,12/14/2021,$800.50\n" \
    "B456,12/21/2021,$740.00\n"
  end

  before do
    create(:header_mapping, employer: employer, key: 'employee_id', value: 'EmployeeNumber')
    create(:header_mapping, employer: employer, key: 'date', value: 'CheckDate')
    create(:header_mapping, employer: employer, key: 'date_format', value: '%m/%d/%Y')
    create(:header_mapping, employer: employer, key: 'amount', value: 'Amount')
  end

  it 'queues the CsvImportWorker for each batch' do
    service = CsvImportService.new(employer, csv_data)
    expect {
      service.import
    }.to change(CsvImportWorker.jobs, :size).by(1)
  end
end
