# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CsvProcessingConfiguration, type: :model do
  it { should validate_presence_of(:date_format) }
  it { should validate_presence_of(:amount_format) }
  it { should validate_presence_of(:currency) }
  it { should validate_presence_of(:start_date) }
  it { should validate_presence_of(:cron_schedule) }
  
  it { should belong_to(:employer) }

end
