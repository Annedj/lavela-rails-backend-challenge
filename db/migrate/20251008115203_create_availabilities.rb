class CreateAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :availabilities do |t|
      t.references :provider, null: false, foreign_key: true
      t.integer :start_day_of_week, null: false
      t.integer :end_day_of_week, null: false
      t.time :starts_at_time, null: false
      t.time :ends_at_time, null: false
      t.string :source, null: false
      t.string :slug, null: false

      t.timestamps
    end
  end
end
