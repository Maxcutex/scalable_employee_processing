# frozen_string_literal: true
# 
require 'rails_helper'

RSpec.describe HeaderMapping, type: :model do
  it { should validate_presence_of(:header_name) }
  it { should validate_presence_of(:mapped_column) }
  
  it { should belong_to(:employer) }

  # Example for custom methods if any
  describe '#some_custom_method' do
    it 'does something' do
      header_mapping = create(:header_mapping)
      expect(header_mapping.some_custom_method).to eq(expected_result)
    end
  end
end
