# frozen_string_literal: true
# 
require 'rails_helper'

RSpec.describe HeaderMapping, type: :model do
  context 'validations' do
    it 'is valid with all attributes' do
      header_mapping = build(:header_mapping)
      expect(header_mapping).to be_valid
    end

    it 'is not valid without a key' do
      header_mapping = build(:header_mapping, key: nil)
      expect(header_mapping).to_not be_valid
      expect(header_mapping.errors[:key]).to include("can't be blank")
    end

    it 'is not valid without a value' do
      header_mapping = build(:header_mapping, value: nil)
      expect(header_mapping).to_not be_valid
      expect(header_mapping.errors[:value]).to include("can't be blank")
    end
  end
end
