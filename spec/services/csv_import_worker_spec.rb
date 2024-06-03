# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe CsvImportWorker, type: :worker do
  let(:employer) { create(:employer) }
  let!(:employee) { create(:employee, employer: employer, name: 'Test1', external_ref: 'A123') }
  let!(:employee2) { create(:employee, employer: employer, name: 'Test2', external_ref: 'B456') }
  let(:valid_rows) do
    [
      { 'EmployeeNumber' => 'A123', 'CheckDate' => '12/14/2021', 'Amount' => '$800.50' },
      { 'EmployeeNumber' => 'B456', 'CheckDate' => '12/21/2021', 'Amount' => '$740.00' }
    ]
  end
  let(:invalid_date_rows) { [{ 'EmployeeNumber' => 'A123', 'CheckDate' => 'invalid_date', 'Amount' => '$800.50' }] }
  let(:invalid_amount_rows) do
    [{ 'EmployeeNumber' => 'A123', 'CheckDate' => '12/14/2021', 'Amount' => 'invalid_amount' }]
  end

  let(:nonexistent_employee_rows) do
    [{ 'EmployeeNumber' => 'nonexistent', 'CheckDate' => '12/21/2021', 'Amount' => '$740.00' }]
  end
  before do
    create(:header_mapping, employer: employer, key: 'employee_id', value: 'EmployeeNumber')
    create(:header_mapping, employer: employer, key: 'date', value: 'CheckDate')
    create(:header_mapping, employer: employer, key: 'amount', value: 'Amount')
  end

  describe 'valid CSV rows' do
    it 'processes valid CSV rows and creates earnings' do
      expect do
        CsvImportWorker.new.perform(employer.id, valid_rows)
      end.to change { Earning.count }.by(2)
    end
  end

  describe 'invalid CSV rows' do
    it 'logs an error for invalid date format' do
      error_message = 'CSV Import Worker Error: Invalid date format: invalid_date for row '\
                      '{"EmployeeNumber"=>"A123", "CheckDate"=>"invalid_date", "Amount"=>"$800.50"}'

      expect(Rails.logger).to receive(:error).with(error_message)
      CsvImportWorker.new.perform(employer.id, invalid_date_rows)
    end

    it 'logs an error for invalid amount format' do
      error_message = 'CSV Import Worker Error: Invalid amount format: invalid_amount for row '\
                      '{"EmployeeNumber"=>"A123", "CheckDate"=>"12/14/2021", "Amount"=>"invalid_amount"}'

      expect(Rails.logger).to receive(:error).with(error_message)
      CsvImportWorker.new.perform(employer.id, invalid_amount_rows)
    end

    it 'logs an error if employee number is not found' do
      error_message = 'CSV Import Worker Error: Employee not found for external_ref: nonexistent for row '\
                      '{"EmployeeNumber"=>"nonexistent", "CheckDate"=>"12/21/2021", "Amount"=>"$740.00"}'

      expect(Rails.logger).to receive(:error).with(error_message)
      CsvImportWorker.new.perform(employer.id, nonexistent_employee_rows)
    end
  end
end
