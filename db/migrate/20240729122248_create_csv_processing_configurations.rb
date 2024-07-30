class CreateCsvProcessingConfigurations < ActiveRecord::Migration[7.1]
  def change
    create_table :csv_processing_configurations do |t|
      t.references :employer, null: false, foreign_key: true
      t.string :date_format, default: '%m/%d/%Y'
      t.string :amount_format, default: 'dollars'
      t.string :currency, default: 'USD'
      
      t.timestamps
    end
  end
end
