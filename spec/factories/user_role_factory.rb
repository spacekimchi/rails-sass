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
