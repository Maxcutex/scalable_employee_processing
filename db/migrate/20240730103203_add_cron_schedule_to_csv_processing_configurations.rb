class AddCronScheduleToCsvProcessingConfigurations < ActiveRecord::Migration[7.1]
  def change
    add_column :csv_processing_configurations, :cron_schedule, :string
  end
end
