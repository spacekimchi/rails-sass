FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    remember_token { Faker::Internet.password }
  end
end
