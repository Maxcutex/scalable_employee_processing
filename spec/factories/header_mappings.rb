# frozen_string_literal: true

FactoryBot.define do
  factory :header_mapping do
    employer
    key { 'employee_id' }
    value { 'EmployeeNumber' }
  end
end
