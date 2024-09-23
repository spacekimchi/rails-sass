# == Schema Information
#
# Table name: users
#
#  id                    :bigint           not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  username              :string           not null
#  email                 :string           not null
#  encrypted_password    :string(128)      not null
#  confirmation_token    :string(128)
#  remember_token        :string(128)      not null
#  stripe_customer_id    :string
#  verification_token    :string
#  verified_at           :datetime
#  verified_requested_at :datetime
#
class User < ApplicationRecord
  include Clearance::User

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :user_subscriptions, dependent: :destroy

  scope :active_users, lambda {
    joins(:user_subscriptions)
      .where(user_subscriptions: { status: [UserSubscription::STATUSES[:ACTIVE]] })
      .where('current_period_end > ?', StripeService.get_stripe_time_now)
  }

  def generate_verification_token
    update(verification_token: SecureRandom.hex(3))
  end

  def complete_verification
    update(verified_at: Time.current)
    create_stripe_customer
  end

  def verified?
    verified_at.present?
  end

  def create_stripe_customer
    # TODO: Remove this function from a after_create callback.
    # Try not to use any after_create callbacks. It gets hard to debug
    return if stripe_customer_id.present? || Rails.env.test?
    Stripe::Customer.create(email: email, metadata: { user_id: id })
  rescue Stripe::InvalidRequestError => e
    # TODO: Somehow make this email or track the errors somehow and notify me
    puts "An invalid request occurred. error: #{e}"
  rescue Stripe::StripeError => e
    puts "Another problem occurred, maybe unrelated to Stripe. error: #{e}"
  end

  def admin?
    roles.admin.present?
  end

  def super_admin?
    roles.super_admin.present?
  end

  def make_admin
    return if admin?
    user_roles.create(role: Role.admin)
  end

  def make_super_admin
    return if super_admin?
    user_roles.create(role: Role.super_admin)
  end

  def remove_admin
    user_roles.where(role: Role.admin).destroy_all
  end

  def remove_super_admin
    user_roles.where(role: Role.super_admin).destroy_all
  end

  def toggle_admin
    if admin?
      remove_admin
    else
      make_admin
    end
  end

  def toggle_super_admin
    if admin?
      remove_super_admin
    else
      make_super_admin
    end
  end

  def is_subscribed_to_product?(product)
    user_subscriptions.active.where(product: product).present?
  end
end
