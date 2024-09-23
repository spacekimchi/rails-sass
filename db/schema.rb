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

ActiveRecord::Schema[7.1].define(version: 2024_09_21_204149) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "application_errors", force: :cascade do |t|
    t.text "message"
    t.integer "level"
    t.integer "code"
    t.text "calling_function"
    t.text "stack_trace"
    t.text "url"
    t.text "user_id"
    t.text "user_ip"
    t.text "user_agent"
    t.boolean "is_resolved"
    t.datetime "resolved_at"
    t.text "notes"
    t.jsonb "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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

  create_table "support_ticket_messages", force: :cascade do |t|
    t.bigint "support_ticket_id", null: false
    t.bigint "user_id", null: false
    t.text "content", null: false
    t.text "recipient_email"
    t.boolean "internal", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["support_ticket_id"], name: "index_support_ticket_messages_on_support_ticket_id"
    t.index ["user_id"], name: "index_support_ticket_messages_on_user_id"
  end

  create_table "support_tickets", force: :cascade do |t|
    t.bigint "user_id"
    t.string "author_email", null: false
    t.string "subject", null: false
    t.integer "status", default: 0, null: false
    t.integer "priority", default: 0, null: false
    t.text "content", null: false
    t.datetime "resolved_at"
    t.bigint "assigned_to_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_to_id"], name: "index_support_tickets_on_assigned_to_id"
    t.index ["author_email"], name: "index_support_tickets_on_author_email"
    t.index ["priority"], name: "index_support_tickets_on_priority"
    t.index ["status"], name: "index_support_tickets_on_status"
    t.index ["user_id"], name: "index_support_tickets_on_user_id"
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
    t.string "username", null: false
    t.string "email", null: false
    t.string "encrypted_password", limit: 128, null: false
    t.string "confirmation_token", limit: 128
    t.string "remember_token", limit: 128, null: false
    t.string "stripe_customer_id"
    t.string "verification_token"
    t.datetime "verified_at"
    t.datetime "verified_requested_at"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["remember_token"], name: "index_users_on_remember_token", unique: true
    t.index ["stripe_customer_id"], name: "index_users_on_stripe_customer_id", unique: true
  end

  add_foreign_key "product_prices", "products"
  add_foreign_key "support_ticket_messages", "support_tickets"
  add_foreign_key "support_ticket_messages", "users"
  add_foreign_key "support_tickets", "users"
  add_foreign_key "support_tickets", "users", column: "assigned_to_id"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
  add_foreign_key "user_subscriptions", "product_prices"
  add_foreign_key "user_subscriptions", "products"
  add_foreign_key "user_subscriptions", "users"
end
