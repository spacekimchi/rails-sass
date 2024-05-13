class CreateProductPrices < ActiveRecord::Migration[7.1]
  def change
    create_table :product_prices do |t|
      t.references :product, null: false, foreign_key: true
      t.string :stripe_price_id, limit: 128
      t.string :name, limit: 128, null: false
      t.integer :price, null: false, default: 0 # price in cents
      t.boolean :is_active, null: false, default: true
      t.integer :interval, null: false # { lifetime: 0, day: 1, week: 2, month: 3, year: 4 }
      t.string :description
      t.string :lookup_key, limit: 128
      t.string :currency, default: 'usd'

      t.timestamps
    end

    add_index :product_prices, :stripe_price_id, unique: true
    add_index :product_prices, :lookup_key, unique: true
  end
end
