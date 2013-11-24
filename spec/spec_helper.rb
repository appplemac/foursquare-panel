# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

require 'factory_girl'
require 'rspec'
require 'faker'
require 'webmock/rspec'
require 'foursquare2'
require_relative '../venue'
require_relative '../form_object'
require_relative '../counter'
require_relative '../helpers'


WebMock.disable_net_connect!(allow_localhost: true)
RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, /api.foursquare.com/).
        to_return(lambda { |request|
            File.new("spec/stubs/get#{request.uri.path.gsub(/\//, '_')}.json")
                  })

  end
end

FactoryGirl.define do
  factory :venue do
    venue_id Faker::Number.number(15)
    name Faker::Company.name
    city Faker::Address.city
    state Faker::Address.state
    phone Faker::PhoneNumber.phone_number
    primaryCategoryId Faker::Lorem.word
  end

  factory :form_object do
    ignore do
      quant 5
    end
    common({name: Faker::Company.name, city: Faker::Address.city,
            state: Faker::Address.state,
            phone: Faker::PhoneNumber.phone_number,
            primaryCategoryId: Faker::Lorem.word})

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
