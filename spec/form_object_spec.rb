# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

require 'spec_helper'

describe FormObject do
  before :each do
    @form_object = FactoryGirl.build(:form_object)
  end
  it "has a valid factory" do
    expect(@form_object).to be_kind_of(FormObject)
  end

  it "has five venues inside" do
    expect(@form_object.ids.size).to eq 5
  end

  it "can have fifteen venues inside" do
    @form_object = FactoryGirl.build(:form_object, quant: 15)
    expect(@form_object.ids.size).to eq 15
  end

  it "produces five venues" do
    expect(@form_object.parse.size).to eq 5
  end

  it "can produce fifteen venues" do
    @form_object = FactoryGirl.build(:form_object, quant: 15)
    expect(@form_object.parse.size).to eq 15
  end

  it "produces real venues" do
    expect(@form_object.parse.first).to be_kind_of(Venue)
  end
end
