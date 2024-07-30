# frozen_string_literal: true

# lib/tasks/schedule.rake
namespace :schedule do
  desc 'Schedule CSV processing for employers'
  task setup: :environment do
    ScheduleService.schedule_employers
    puts 'Schedules have been set up or updated for all employers.'
  end
end
