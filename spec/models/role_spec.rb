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
require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(build(:role, name: :admin)).to be_valid
    end

    it 'is not valid when name is not in the name enum' do
      role = build(:role)
      expect { role.name = Faker::Number.hexadecimal }.to raise_error(ArgumentError)
      Role::NAMES.each do |name|
        expect { role.name = name }.to_not raise_error
      end
    end
  end

  describe 'methods' do
    let(:admin_role) { create(:role, :admin) }
    let(:super_admin_role) { create(:role, :super_admin) }

    it 'correctly identifies an admin role' do
      expect(admin_role.admin?).to be true
      expect(admin_role.super_admin?).to be false
    end

    it 'correctly identifies a super_admin role' do
      expect(super_admin_role.super_admin?).to be true
      expect(super_admin_role.admin?).to be false
    end
  end
end

