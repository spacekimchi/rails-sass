class CreateUserSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :user_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :product, foreign_key: true
      t.references :product_price, foreign_key: true
      t.string :stripe_subscription_id, limit: 128
      t.string :status
      t.bigint :current_period_start
      t.bigint :current_period_end

      t.timestamps
    end

    add_index :user_subscriptions, :stripe_subscription_id, unique: true
  end
end
