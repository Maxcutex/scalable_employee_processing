class CreateProcessedFiles < ActiveRecord::Migration[7.1]
  def change
    create_table :processed_files do |t|
      t.references :employer, null: false, foreign_key: true
      t.string :file_key

      t.timestamps
    end
  end
end
