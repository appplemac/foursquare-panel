# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

require 'spec_helper'

class TestHelper
  include Helpers
end

describe Helpers do
  let(:helpers) { TestHelper.new }

  it "knows which ids are whitelisted" do
    expect(helpers.in_whitelist?(12277667)).to be_true
  end

  it "knows which ids are not whitelisted" do
    expect(helpers.in_whitelist?(1)).to be_false
  end

  it "searches for a page with given twitter handle" do
    api_client = Foursquare2::Client.new(:oauth_token => 'QWERTYUIOPASDFGHJKLZXCVBNM')
    expect(helpers.page_id_from_user_input(api_client, "starbucks_es")).
        to eq "8531311"
  end

  it "returns an unchanged page id when given a page id" do
    api_client = Foursquare2::Client.new(:oauth_token => 'QWERTYUIOPASDFGHJKLZXCVBNM')
    expect(helpers.page_id_from_user_input(api_client, "8531311")).
        to eq "8531311"
  end
end
