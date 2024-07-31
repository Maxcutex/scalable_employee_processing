# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessedFile, type: :model do
  context 'validations' do
    it 'is valid with an employer and file_key' do
      employer = Employer.create(name: 'Test Employer')
      processed_file = ProcessedFile.create(
        employer: employer,
        file_key: 'unique_file_key_123'
      )
      expect(processed_file).to be_valid
    end

    it 'is not valid without an employer' do
      processed_file = ProcessedFile.create(file_key: 'unique_file_key_123')
      expect(processed_file).to_not be_valid
      expect(processed_file.errors[:employer]).to include("must exist")
    end

    it 'is not valid without a file_key' do
      employer = Employer.create(name: 'Test Employer')
      processed_file = ProcessedFile.create(employer: employer)
      expect(processed_file).to_not be_valid
      expect(processed_file.errors[:file_key]).to include("can't be blank")
    end
  end

  context 'associations' do
    it 'belongs to an employer' do
      employer = Employer.create(name: 'Test Employer')
      processed_file = ProcessedFile.create(
        employer: employer,
        file_key: 'unique_file_key_123'
      )
      expect(processed_file.employer).to eq(employer)
    end
  end
end
