# frozen_string_literal: true

FactoryBot.define do
  factory :employer do
    name { Faker::Company.name }

    after(:create) do |employer|
      create(:csv_processing_configuration, employer: employer)
    end
  end

  factory :csv_processing_configuration do
    employer
    date_format { '%m/%d/%Y' }
    amount_format { 'dollars' }
    currency { 'USD' }
    start_date { '2024-01-01' }
    cron_schedule { '0 0 * * *' }
  end
end
