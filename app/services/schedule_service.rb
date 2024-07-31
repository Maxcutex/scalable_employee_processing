

# ScheduleService manages the scheduling of CSV processing jobs for employers.
# It ensures that each employer's CSV processing is scheduled according to their cron schedule and start date.
class ScheduleService
  def self.schedule_employers
    Employer.find_each do |employer|
      config = employer.csv_processing_configuration
      next if config.blank? || config.cron_schedule.blank?

      existing_schedule = find_existing_schedule(employer.id)

      if existing_schedule
        # Check if cron schedule or start date has changed
        if needs_update?(existing_schedule, config.cron_schedule)
          update_schedule(employer.id, employer.name, existing_schedule, config.cron_schedule)
        end
      else
        create_schedule(employer.id, employer.name, config.cron_schedule)
      end
    end
  end

  # Finds an existing schedule for a given employer ID.
  #
  # @param employer_id [Integer] the ID of the employer
  # @return [Sidekiq::Cron::Job, nil] the existing schedule or nil if not found
  def self.find_existing_schedule(employer_id)
    Sidekiq::Cron::Job.all.find do |job|
      job.args.first == employer_id && job.name.include?('CsvProcessingJob for Employer')
    end
  end

  # Determines if the existing schedule needs to be updated based on the new cron schedule and start date.
  #
  # @param schedule [Sidekiq::Cron::Job] the existing schedule
  # @param new_cron_schedule [String] the new cron schedule
  # @return [Boolean] true if the schedule needs to be updated, false otherwise
  def self.needs_update?(schedule, new_cron_schedule)
    schedule.cron != new_cron_schedule
  end

  # Updates an existing schedule with a new cron schedule and start date.
  #
  # @param employer_id [Integer] the ID of the employer
  # @param employer_name [String] the name of the employer
  # @param schedule [Sidekiq::Cron::Job] the existing schedule to update
  # @param new_cron_schedule [String] the new cron schedule
  def self.update_schedule(employer_id, employer_name, schedule, new_cron_schedule)
    Sidekiq::Cron::Job.destroy schedule.name
    create_schedule(employer_id, employer_name, new_cron_schedule)
  end

  # Creates a new schedule for an employer.
  #
  # @param employer_id [Integer] the ID of the employer
  # @param employer_name [String] the name of the employer
  # @param cron_schedule [String] the cron schedule
  def self.create_schedule(employer_id, employer_name, cron_schedule)
    Sidekiq::Cron::Job.create(
      name: "CsvProcessingJob for Employer #{employer_name}",
      cron: cron_schedule,
      class: 'CsvProcessingWorker',
      args: [employer_id],
      description: "Processes CSV for employer #{employer_name}"
    )
  end
end
