# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Employer, type: :model do
  context 'validations' do
    it 'is valid with a name' do
      employer = build(:employer)
      expect(employer).to be_valid
    end

    it 'is not valid without a name' do
      employer = build(:employer, name: nil)
      expect(employer).to_not be_valid
      expect(employer.errors[:name]).to include("can't be blank")
    end
  end

  context 'associations' do
    it 'has one csv_processing_configuration' do
      employer = Employer.create(name: 'Test Employer')
      config = CsvProcessingConfiguration.create(
        employer: employer,
        date_format: '%m/%d/%Y',
        amount_format: 'dollars',
        currency: 'USD',
        start_date: '2024-01-01',
        cron_schedule: '0 0 * * *'
      )
      
      expect(employer.csv_processing_configuration).to eq(config)
    end

    it 'has many employees' do
      employer = Employer.create(name: 'Test Employer')
      employee1 = Employee.create(
        employer: employer,
        external_ref: 'E123',
        name: 'John Doe',
      )

      employee2 = Employee.create(
        employer: employer,
        external_ref: 'E124',
        name: 'Jane Smith',
      )

      expect(employer.employees).to include(employee1, employee2)
      expect(employer.employees.count).to eq(2)
    end
  end
end
