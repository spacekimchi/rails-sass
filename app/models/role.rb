# == Schema Information
#
# Table name: roles
#
#  id          :bigint           not null, primary key
#  name        :integer
#  description :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Role < ApplicationRecord
  ADMIN = 'admin'.freeze
  SUPER_ADMIN = 'super_admin'.freeze

  NAMES = [ADMIN, SUPER_ADMIN].freeze
  enum name: { admin: 0, super_admin: 1 }

  has_many :user_roles
  has_many :users, through: :user_roles

  # Validates that the name is included in the keys of the enum definition
  validates :name, inclusion: { in: names.keys }

  def self.admin
    Role.find_by(name: ADMIN)
  end

  def self.super_admin
    Role.find_by(name: SUPER_ADMIN)
  end

  def admin?
    name == ADMIN
  end

  def super_admin?
    name == SUPER_ADMIN
  end
end
