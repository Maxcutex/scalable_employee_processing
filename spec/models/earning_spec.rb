# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Earning, type: :model do
  let(:employee) { create(:employee) }

  context 'validations' do
    it 'is valid with all attributes' do
      earning = build(:earning, employee: employee)
      expect(earning).to be_valid
    end

    it 'is not valid without an amount' do
      earning = build(:earning, amount: nil, employee: employee)
      expect(earning).to_not be_valid
      expect(earning.errors[:amount]).to include("can't be blank")
    end

    it 'is not valid without a earning_date' do
      earning = build(:earning, earning_date: nil, employee: employee)
      expect(earning).to_not be_valid
      expect(earning.errors[:earning_date]).to include("can't be blank")
    end
  end

  context 'associations' do
    it { should belong_to(:employee) }
  end
end

