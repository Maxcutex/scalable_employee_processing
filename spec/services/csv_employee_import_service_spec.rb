# frozen_string_literal: true

# spec/workers/csv_import_worker_spec.rb

require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe CsvEmployeeImportService do
  let(:employer) { create(:employer) }
  let!(:employee) { create(:employee, employer: employer, external_ref: 'A123') }
  let(:date_format) { '%m/%d/%Y' }
  let(:exchange_rate) { 1.0 }
  let(:header_mappings) do
    { 'employee_id' => 'EmployeeNumber', 'date' => 'CheckDate', 'amount' => 'Amount' }
  end

  describe '#run' do
    context 'with valid rows' do
      let(:valid_rows) do
        [{ 'EmployeeNumber' => 'A123', 'CheckDate' => '12/14/2021', 'Amount' => '$800.50' }]
      end

      it 'creates earnings' do
        expect do
          CsvEmployeeImportService.new(employer.id, valid_rows, date_format, exchange_rate, header_mappings).run
        end
          .to change { Earning.count }.by(1)

        earning = Earning.last
        expect(earning.employee_id).to eq(employee.id)
        expect(earning.amount).to eq(800.50)
        expect(earning.earning_date.to_s).to eq('2021-12-14')
      end
    end

    context 'with invalid amount format' do
      let(:invalid_amount_rows) do
        [{ 'EmployeeNumber' => 'A123', 'CheckDate' => '12/14/2021', 'Amount' => 'invalid_amount' }]
      end

      it 'logs an error with employee ID' do
        expect(Rails.logger).to receive(:error)
          .with('CSV Import Worker Error: Invalid Amount: invalid_amount for employee ID A123')
        CsvEmployeeImportService.new(employer.id, invalid_amount_rows, date_format, exchange_rate,
                                     header_mappings).run
      end
    end

    context 'with invalid date format' do
      let(:invalid_date_rows) do
        [{ 'EmployeeNumber' => 'A123', 'CheckDate' => 'invalid_date', 'Amount' => '$800.50' }]
      end

      it 'logs an error with employee ID' do
        expect(Rails.logger).to receive(:error)
          .with('CSV Import Worker Error: Invalid date format: invalid_date for employee ID A123')
        CsvEmployeeImportService.new(employer.id, invalid_date_rows, date_format, exchange_rate, header_mappings).run
      end
    end

    context 'when employee number is not found' do
      let(:nonexistent_employee_rows) do
        [{ 'EmployeeNumber' => 'nonexistent', 'CheckDate' => '12/21/2021', 'Amount' => '$740.00' }]
      end

      it 'logs an error with employee ID' do
        expect(Rails.logger).to receive(:error)
          .with('CSV Import Worker Error: Employee not found for external_ref: nonexistent for employee ID nonexistent')
        CsvEmployeeImportService.new(employer.id, nonexistent_employee_rows, date_format, exchange_rate,
                                     header_mappings).run
      end
    end
  end
end
