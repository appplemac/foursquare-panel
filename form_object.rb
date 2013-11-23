# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

class FormObject
  attr_accessor :ids, :common

  def initialize(opts = {})
    @ids = opts[:ids]
    @common = opts[:common]
  end

  def parse
    venues = []
    unless @ids.respond_to?(:each)
      venues << Venue.new(@common.merge(venue_id: @ids))
    else
      @ids.each do |id|
        venues << Venue.new(@common.merge(venue_id: id))
      end
    end

    venues
  end
end
