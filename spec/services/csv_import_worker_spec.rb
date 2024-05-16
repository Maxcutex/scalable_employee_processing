require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe CsvImportWorker, type: :worker do
  let(:employer) { create(:employer) }
  let(:employee) { create(:employee, employer: employer, external_ref: 'A123') }
  let(:rows) do
    [
      { 'EmployeeNumber' => 'A123', 'CheckDate' => '12/14/2021', 'Amount' => '$800.50' },
      { 'EmployeeNumber' => 'B456', 'CheckDate' => '12/21/2021', 'Amount' => '$740.00' }
    ]
  end

  before do
    create(:header_mapping, employer: employer, key: 'employee_id', value: 'EmployeeNumber')
    create(:header_mapping, employer: employer, key: 'date', value: 'CheckDate')
    create(:header_mapping, employer: employer, key: 'date_format', value: '%m/%d/%Y')
    create(:header_mapping, employer: employer, key: 'amount', value: 'Amount')
  end

  it 'processes CSV rows and creates earnings' do
    expect {
      CsvImportWorker.new.perform(employer.id, rows)
    }.to change { Earning.count }.by(2)
  end
end
