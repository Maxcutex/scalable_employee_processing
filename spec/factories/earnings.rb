# frozen_string_literal: true

FactoryBot.define do
  factory :earning do
    employee
    earning_date { Faker::Date.backward(days: 30) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
  end
end
