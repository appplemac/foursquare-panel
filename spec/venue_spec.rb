require 'spec_helper'

describe Venue do
  before :each do
    @venue = FactoryGirl.build(:venue)
  end
  it "builds a venue" do
    expect(@venue).to be_kind_of(Venue)
  end

  it "generates a hash of attributes" do
    hash = {name: @venue.name, city: @venue.city, state: @venue.state,
            phone: @venue.phone, primaryCategoryId: @venue.primaryCategoryId,
            venue_id: @venue.venue_id}
    expect(@venue.to_h).to eq hash
  end
end
