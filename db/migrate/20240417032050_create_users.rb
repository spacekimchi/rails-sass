class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.timestamps null: false
      t.string :username, null: false
      t.string :email, null: false
      t.string :encrypted_password, limit: 128, null: false
      t.string :confirmation_token, limit: 128
      t.string :remember_token, limit: 128, null: false
      t.string :stripe_customer_id
      t.string :verification_token
      t.datetime :verified_at
      t.datetime :verified_requested_at
    end

    add_index :users, :stripe_customer_id, unique: true
    add_index :users, :email, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :remember_token, unique: true
  end
end
