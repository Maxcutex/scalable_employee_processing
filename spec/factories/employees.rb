# frozen_string_literal: true

FactoryBot.define do
  factory :employee do
    employer
    name { Faker::Name.name }
    external_ref { Faker::Alphanumeric.alpha(number: 10) }
  end
end
