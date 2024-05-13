class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :stripe_product_id, limit: 128
      t.string :name, limit: 128, null: false
      t.string :description
      t.boolean :for_subscription, null: false, default: true
      t.boolean :is_active, null: false, default: true

      t.timestamps
    end

    add_index :products, :stripe_product_id, unique: true
  end
end
