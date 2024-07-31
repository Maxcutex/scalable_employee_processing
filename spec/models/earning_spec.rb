# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Earning, type: :model do
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:date) }
  
  it { should belong_to(:employer) }

  # Example for custom methods if any
  describe '#calculate_total' do
    it 'calculates the total earnings' do
      employer = create(:employer)
      create(:earning, employer: employer, amount: 100)
      create(:earning, employer: employer, amount: 200)

      expect(employer.earnings.calculate_total).to eq(300)
    end
  end
end
