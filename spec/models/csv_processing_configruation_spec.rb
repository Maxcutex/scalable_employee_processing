# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CsvProcessingConfiguration, type: :model do
  let(:employer) { create(:employer) }

  context 'validations' do
    it 'is valid with all attributes' do
      config = build(:csv_processing_configuration, employer: employer)
      expect(config).to be_valid
    end

    it 'is not valid without a date_format' do
      config = build(:csv_processing_configuration, date_format: nil, employer: employer)
      expect(config).to_not be_valid
      expect(config.errors[:date_format]).to include("can't be blank")
    end

    it 'is not valid without an amount_format' do
      config = build(:csv_processing_configuration, amount_format: nil, employer: employer)
      expect(config).to_not be_valid
      expect(config.errors[:amount_format]).to include("can't be blank")
    end

    it 'is not valid without a currency' do
      config = build(:csv_processing_configuration, currency: nil, employer: employer)
      expect(config).to_not be_valid
      expect(config.errors[:currency]).to include("can't be blank")
    end

    it 'is not valid without a start_date' do
      config = build(:csv_processing_configuration, start_date: nil, employer: employer)
      expect(config).to_not be_valid
      expect(config.errors[:start_date]).to include("can't be blank")
    end

    it 'is not valid without a cron_schedule' do
      config = build(:csv_processing_configuration, cron_schedule: nil, employer: employer)
      expect(config).to_not be_valid
      expect(config.errors[:cron_schedule]).to include("can't be blank")
    end
  end

  context 'associations' do
    it { should belong_to(:employer) }
  end

 
end

