require 'spec_helper'

describe Counter do
  before :each do
    @counter = FactoryGirl.build(:counter)
  end

  it "counts successes correctly" do
    success_count = @counter.success
    3.times do
      @counter.success!
    end
    expect(@counter.success).to eq (success_count + 3)
  end

  it "counts failures correctly" do
    failure_count = @counter.failure
    5.times do
      @counter.failure!
    end
    expect(@counter.failure).to eq (failure_count + 5)
  end
end
