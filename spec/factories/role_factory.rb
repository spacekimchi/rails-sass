FactoryBot.define do
  factory :role do
    name { Role::NAMES.sample }
    description { Faker::Lorem.sentence }

    trait :admin do
      name { Role::ADMIN }
      description { 'This is an admin user' }
    end

    trait :super_admin do
      name { Role::SUPER_ADMIN }
      description { 'This is a super admin user' }
    end
  end
end
