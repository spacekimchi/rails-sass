class CreateApplicationErrors < ActiveRecord::Migration[7.1]
  def change
    create_table :application_errors do |t|
      t.text :message
      t.integer :level # enum
      t.integer :code
      t.text :calling_function
      t.text :stack_trace
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
