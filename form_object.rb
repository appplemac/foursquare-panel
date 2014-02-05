# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

class FormObject
  def initialize(api_client, ids, common = {})
    @api_client = api_client
    @ids = ids
    @common = common
  end

  def parse
    unless @api_client.is_a?(Foursquare2::Client)
      raise ArgumentError('The API client is not correct')
    end
    venues = []
    if @ids.respond_to?(:each)
      @ids.each do |id|
        venues << Venue.new(id, @api_client, @common)
      end
    else
      venues << Venue.new(@ids, @api_client, @common)
    end
    venues
  end
end
