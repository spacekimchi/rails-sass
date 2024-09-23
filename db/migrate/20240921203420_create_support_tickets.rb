class CreateSupportTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :support_tickets do |t|
      t.references :user, foreign_key: true, null: true
      t.string :author_email, null: false
      t.string :subject, null: false
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 0
      t.text :content, null: false
      t.datetime :resolved_at
      t.references :assigned_to, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :support_tickets, :status
    add_index :support_tickets, :priority
    add_index :support_tickets, :author_email
  end
end
