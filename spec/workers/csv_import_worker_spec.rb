# frozen_string_literal: true

# spec/workers/csv_import_worker_spec.rb

require 'rails_helper'
require 'sidekiq/testing'

Sidekiq::Testing.fake!

RSpec.describe CsvImportWorker, type: :worker do
  let(:employer) { build(:employer) }
  let!(:employee) { build(:employee, employer: employer, external_ref: 'A123') }
  let(:date_format) { '%m/%d/%Y' }
  let(:exchange_rate) { 1.0 }

  describe '#perform' do
    let(:rows) do
      [{ 'EmployeeNumber' => 'A123', 'CheckDate' => '12/14/2021', 'Amount' => '$800.50' }]
    end

    let(:header_mappings) do
      {}
    end
    it 'calls CsvEmployeeImportService' do
      expect(CsvEmployeeImportService).to receive(:new)
        .with(employer.id, rows, date_format, exchange_rate, header_mappings)
        .and_return(double(run: nil))
      CsvImportWorker.new.perform(employer.id, rows, date_format, exchange_rate, header_mappings)
    end
  end
end
