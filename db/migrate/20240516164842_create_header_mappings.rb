class CreateHeaderMappings < ActiveRecord::Migration[7.1]
  def change
    create_table :header_mappings do |t|
      t.references :employer, null: false, foreign_key: true
      t.string :key
      t.string :value

      t.timestamps
    end
  end
end
