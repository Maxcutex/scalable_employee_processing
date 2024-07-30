# frozen_string_literal: true

FactoryBot.define do
  factory :processed_file do
    employer { nil }
    file_key { 'MyString' }
  end
end
