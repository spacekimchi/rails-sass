# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_05_12_055709) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.boolean "is_visible", default: true, null: false
    t.boolean "is_sim", default: false, null: false
    t.boolean "is_pa", default: false, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "executions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.bigint "trade_id"
    t.string "execution_id", null: false
    t.string "order_id", null: false
    t.string "ticker", null: false
    t.decimal "fill_time", null: false
    t.float "commission", null: false
    t.float "price", null: false
    t.integer "quantity", null: false
    t.boolean "is_entry", null: false
    t.boolean "is_buy", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_executions_on_account_id"
    t.index ["execution_id"], name: "index_executions_on_execution_id", unique: true
    t.index ["trade_id"], name: "index_executions_on_trade_id"
    t.index ["user_id", "account_id"], name: "index_executions_on_user_id_and_account_id"
    t.index ["user_id", "fill_time"], name: "index_executions_on_user_id_and_fill_time"
    t.index ["user_id", "trade_id"], name: "index_executions_on_user_id_and_trade_id"
    t.index ["user_id"], name: "index_executions_on_user_id"
  end

  create_table "product_prices", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.string "stripe_price_id", limit: 128
    t.string "name", limit: 128, null: false
    t.integer "price", default: 0, null: false
    t.boolean "is_active", default: true, null: false
    t.integer "interval", null: false
    t.string "description"
    t.string "lookup_key", limit: 128
    t.string "currency", default: "usd"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lookup_key"], name: "index_product_prices_on_lookup_key", unique: true
    t.index ["product_id"], name: "index_product_prices_on_product_id"
    t.index ["stripe_price_id"], name: "index_product_prices_on_stripe_price_id", unique: true
  end

  create_table "products", force: :cascade do |t|
    t.string "stripe_product_id", limit: 128
    t.string "name", limit: 128, null: false
    t.string "description"
    t.boolean "for_subscription", default: true, null: false
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_product_id"], name: "index_products_on_stripe_product_id", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.integer "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "stripe_webhook_errors", force: :cascade do |t|
    t.string "message"
    t.string "stripe_customer_id"
    t.json "event_object"
    t.string "event_type"
    t.boolean "is_resolved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "trades", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "account_id", null: false
    t.string "ticker", null: false
    t.decimal "entry_time", null: false
    t.decimal "exit_time", null: false
    t.float "commission", null: false
    t.float "pnl", default: 0.0, null: false
    t.boolean "is_long", null: false
    t.boolean "is_open", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_trades_on_account_id"
    t.index ["user_id", "account_id"], name: "index_trades_on_user_id_and_account_id"
    t.index ["user_id", "entry_time"], name: "index_trades_on_user_id_and_entry_time"
    t.index ["user_id", "exit_time"], name: "index_trades_on_user_id_and_exit_time"
    t.index ["user_id"], name: "index_trades_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "user_subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "product_id"
    t.bigint "product_price_id"
    t.string "stripe_subscription_id", limit: 128
    t.string "status"
    t.bigint "current_period_start"
    t.bigint "current_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_user_subscriptions_on_product_id"
    t.index ["product_price_id"], name: "index_user_subscriptions_on_product_price_id"
    t.index ["stripe_subscription_id"], name: "index_user_subscriptions_on_stripe_subscription_id", unique: true
    t.index ["user_id"], name: "index_user_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.string "activation_token", null: false
    t.string "ninja_trader_id"
    t.string "stripe_customer_id"
    t.datetime "activated_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["ninja_trader_id"], name: "index_users_on_ninja_trader_id", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "executions", "accounts"
  add_foreign_key "executions", "trades"
  add_foreign_key "executions", "users"
  add_foreign_key "product_prices", "products"
  add_foreign_key "trades", "accounts"
  add_foreign_key "trades", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "user_subscriptions", "product_prices"
  add_foreign_key "user_subscriptions", "products"
  add_foreign_key "user_subscriptions", "users"
end
