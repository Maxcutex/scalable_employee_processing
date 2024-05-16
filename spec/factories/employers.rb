FactoryBot.define do
    factory :employer do
      name { Faker::Company.name }
    end
  end
  