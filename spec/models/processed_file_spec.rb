# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProcessedFile, type: :model do
  it { should validate_presence_of(:file_name) }
  it { should validate_presence_of(:processed_at) }
  
  it { should belong_to(:employer) }

  # Example for custom methods if any
  describe '#some_custom_method' do
    it 'does something' do
      processed_file = create(:processed_file)
      expect(processed_file.some_custom_method).to eq(expected_result)
    end
  end
end
