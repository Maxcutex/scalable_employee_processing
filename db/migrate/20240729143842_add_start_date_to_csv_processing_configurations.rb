class AddStartDateToCsvProcessingConfigurations < ActiveRecord::Migration[7.1]
  def change
    add_column :csv_processing_configurations, :start_date, :datetime
  end
end
