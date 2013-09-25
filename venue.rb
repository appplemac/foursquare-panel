class Venue
  attr_accessor :venue_id, :name, :city, :state, :phone, :cat_id

  def initialize(options = {})
    options.reject {|_,v| v.empty? }.each do |k,v|
      self.send("#{k.to_s}=".to_sym, v)
    end
  end

  def to_h
    props = {}
    [:name, :city, :state, :phone].each do |attr|
      unless self.send(attr).nil?
        props[attr] = self.send(attr)
      end
    end
    # special cases
    unless self.cat_id.nil?
      props[:primaryCategoryId] = @cat_id
    end
    props
  end

  def edit!(client)
    unless client.is_a?(Foursquare2::Client)
      raise ArgumentError, "Client looks invalid"
    end
    client.propose_venue_edit(@venue_id, self.to_h)
  end
end
