# frozen_string_literal: true

FactoryBot.define do
  factory :employer do
    name { Faker::Company.name }
  end
end
