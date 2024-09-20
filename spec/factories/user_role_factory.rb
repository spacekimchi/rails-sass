# == Schema Information
#
# Table name: user_roles
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  role_id    :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :user_role do
    user

    trait :with_admin do
      association :role, factory: [:role, :admin]
    end

    trait :with_super_admin do
      association :role, factory: [:role, :super_admin]
    end
  end
end
