class CreateApplicationErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :application_errors do |t|
      t.text :message, null: false
      t.integer :level, null: false, default: 0
      t.text :calling_function
      t.text :backtrace
      t.text :url
      t.text :user_id
      t.text :user_ip
      t.text :user_agent # User's browser/device information.
      t.boolean :is_resolved
      t.datetime :resolved_at
      t.text :notes
      t.jsonb :data

      t.timestamps
    end
  end
end
