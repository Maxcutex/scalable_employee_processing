# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Employer, type: :model do
  it { should validate_presence_of(:name) }
  
  it { should have_one(:csv_processing_configuration).dependent(:destroy) }
  it { should have_many(:earnings).dependent(:destroy) }
  it { should have_many(:header_mappings).dependent(:destroy) }
  it { should have_many(:processed_files).dependent(:destroy) }

  # Example for custom methods if any
  describe '#some_custom_method' do
    it 'does something' do
      employer = create(:employer)
      expect(employer.some_custom_method).to eq(expected_result)
    end
  end
end
