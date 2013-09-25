require 'factory_girl'
require 'rspec'
require 'faker'
require_relative '../venue'
require_relative '../form_object'
require_relative '../counter'

FactoryGirl.define do
  factory :venue do
    venue_id Faker::Number.number(15)
    name Faker::Company.name
    city Faker::Address.city
    state Faker::Address.state
    phone Faker::PhoneNumber.phone_number
    cat_id Faker::Lorem.word
  end

  factory :form_object do
    ignore do
      quant 5
    end
    common({name: Faker::Company.name, city: Faker::Address.city,
            state: Faker::Address.state,
            phone: Faker::PhoneNumber.phone_number,
            cat_id: Faker::Lorem.word})

    after(:build) do |form_object, evaluator|
      form_object.ids = []
      evaluator.quant.times do
        form_object.ids << Faker::Number.number(15)
      end
    end
  end

  factory :counter do
    success Faker::Number.number(2).to_i
    failure Faker::Number.number(2).to_i
  end
end
