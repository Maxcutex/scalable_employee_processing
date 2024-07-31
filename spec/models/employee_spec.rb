# frozen_string_literal: true

require 'rails_helper'

require 'rails_helper'

RSpec.describe Employee, type: :model do
  let(:employer) { create(:employer) }

  context 'validations' do
    it 'is valid with all attributes' do
      employee = build(:employee, employer: employer)
      expect(employee).to be_valid
    end

    it 'is not valid without an external_ref' do
      employee = build(:employee, external_ref: nil, employer: employer)
      expect(employee).to_not be_valid
      expect(employee.errors[:external_ref]).to include("can't be blank")
    end

    it 'is not valid without a name' do
      employee = build(:employee, name: nil, employer: employer)
      expect(employee).to_not be_valid
      expect(employee.errors[:name]).to include("can't be blank")
    end
  end

  context 'associations' do
    it { should belong_to(:employer) }
  end
end
