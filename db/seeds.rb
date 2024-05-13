# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

admin_role = Role.find_or_create_by(name: :admin)
super_admin = Role.find_or_create_by(name: :super_admin)

super_admin_user = User.find_or_create_by(email: 'jin@mts.com') do |user|
  user.password = "password"
end
UserRole.find_or_create_by(user: super_admin_user, role: super_admin)

admin_user = User.find_or_create_by(email: 'admin@mts.com') do |user|
  user.password = "password"
end
UserRole.find_or_create_by(user: admin_user, role: admin_role)

regular_user = User.find_or_create_by(email: 'regular@mts.com') do |user|
  user.password = "password"
end

sub_product = Product.find_or_create_by(
  name: "subscription_#{Faker::Number.rand_in_range(1, 99999)}",
  description: Faker::Name.first_name,
  for_subscription: true,
  is_active: true
)

sub_product.product_prices.create(
  name: "monthly_#{Faker::Number.rand_in_range(1, 99999)}",
  price: 12345,
  is_active: true,
  interval: 3,
  description: Faker::Name.last_name,
  currency: 'usd'
)

sub_product.product_prices.create(
  name: "yearly_#{Faker::Number.rand_in_range(1, 99999)}",
  price: 12345,
  is_active: true,
  interval: 4,
  description: Faker::Name.last_name,
  currency: 'usd'
)

payment_product = Product.find_or_create_by(
  name: "payment_product_#{Faker::Number.rand_in_range(1, 99999)}",
  description: Faker::Name.first_name,
  for_subscription: false,
  is_active: true
)

payment_product.product_prices.create(
  name: "lifetime baby",
  price: 123456,
  is_active: true,
  interval: 0,
  description: Faker::Name.last_name,
  currency: 'usd'
)

