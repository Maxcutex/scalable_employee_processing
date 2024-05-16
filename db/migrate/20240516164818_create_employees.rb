class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :employer, null: false, foreign_key: true
      t.string :name
      t.string :external_ref

      t.timestamps
    end
  end
end
