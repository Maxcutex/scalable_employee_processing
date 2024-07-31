# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Employee, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  
  it { should belong_to(:employer) }
  
  # Example for custom methods if any
  describe '#some_custom_method' do
    it 'does something' do
      employee = create(:employee)
      expect(employee.some_custom_method).to eq(expected_result)
    end
  end
end
