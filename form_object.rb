class FormObject
  attr_accessor :ids, :common

  def initialize(opts = {})
    @ids = opts[:ids]
    @common = opts[:common]
  end

  def parse
    venues = []
    if not @ids.respond_to?(:each)
      venues << Venue.new(@common.merge(venue_id: @ids))
    else
      @ids.each do |id|
        venues << Venue.new(@common.merge(venue_id: id))
      end
    end

    venues
  end
end
