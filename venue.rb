# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

class Venue
  def initialize(venue_id, api_client, options = {})
    @venue_id = venue_id
    @api_client = api_client
    @options = options.reject {|_,v| v.to_s.empty? }
  end

  def to_h
    @options
  end

  def edit!
    unless @client.is_a?(Foursquare2::Client)
      raise ArgumentError, "Client looks invalid"
    end
    @client.edit_venue(@venue_id, @options)
  end
end
