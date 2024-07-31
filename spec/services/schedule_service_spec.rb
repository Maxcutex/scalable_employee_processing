# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe ScheduleService do
  before do
    Sidekiq::Testing.fake! # Ensures jobs are added to the queue but not executed
  end

  let(:employer) { create(:employer) }
  let(:cron_schedule) { '0 0 * * *' }
  let(:start_date) { Date.today }
  let!(:config) do
    create(:csv_processing_configuration, employer: employer, cron_schedule: cron_schedule, start_date: start_date)
  end
  let(:new_cron_schedule) { '0 0 * * 1' }
  let(:job_name) { "CsvProcessingJob for Employer #{employer.name}" }
  let(:existing_schedule) do
    instance_double(Sidekiq::Cron::Job, name: job_name, cron: cron_schedule, args: [employer.id])
  end

  before do
    allow(Sidekiq::Cron::Job).to receive(:create)
    allow(Sidekiq::Cron::Job).to receive(:all).and_return([existing_schedule])
    allow(employer).to receive(:csv_processing_configuration).and_return(config)
  end

  describe '.schedule_employers' do
    context 'when no existing schedule exists' do
      before do
        allow(Sidekiq::Cron::Job).to receive(:all).and_return([])
      end
  
      it 'creates a new schedule' do
        expect(Sidekiq::Cron::Job).to receive(:create).with(
          name: "CsvProcessingJob for Employer #{employer.name}",
          cron: cron_schedule,
          class: 'CsvProcessingWorker',
          args: [employer.id],
          description: "Processes CSV for employer #{employer.name}"
        )
  
        ScheduleService.schedule_employers
      end
    end

    context 'when an existing schedule exists and needs updating' do
      before do
        allow(Sidekiq::Cron::Job).to receive(:destroy).with(job_name)
        allow(Sidekiq::Cron::Job).to receive(:create).with(
          name: "CsvProcessingJob for Employer #{employer.name}",
          cron: new_cron_schedule,
          class: 'CsvProcessingWorker',
          args: [employer.id],
          description: "Processes CSV for employer #{employer.name}"
        )
      end

      it 'destroys the existing schedule and creates a new schedule if cron schedule changes' do
        # Simulate config change
        config.update(cron_schedule: new_cron_schedule)

        ScheduleService.schedule_employers
      end

      it 'does not destroy or create new schedule if cron schedule is the same' do
        expect(Sidekiq::Cron::Job).not_to receive(:destroy)
        expect(Sidekiq::Cron::Job).not_to receive(:create)

        ScheduleService.schedule_employers
      end
    end

    context 'when the configuration is blank or cron schedule is missing' do
      let!(:config) {nil}

      it 'does not create or update any schedules' do
        expect(Sidekiq::Cron::Job).not_to receive(:create)
        expect(Sidekiq::Cron::Job).not_to receive(:all)

        ScheduleService.schedule_employers
      end
    end
  end
end
