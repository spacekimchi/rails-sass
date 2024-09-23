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
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
    remember_token { Faker::Internet.password }
  end
end
