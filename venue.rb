class Venue
  attr_accessor :client, :venue_id, :name, :address, :crossStreet,
                :city, :state, :phone, :categoryId, :twitter,
                :description, :url

  def initialize(options = {})
    options.reject {|_,v| v.to_s.empty? }.each do |k,v|
      self.send("#{k.to_s}=".to_sym, v)
    end
  end

  def to_h
    props = {}
    [:client, :venue_id, :name, :address, :crossStreet,
     :city, :state, :phone, :categoryId, :twitter,
     :description, :url].each do |attr|
      unless self.send(attr).nil?
        props[attr] = self.send(attr)
      end
    end
    props
  end

  def edit!
    unless @client.is_a?(Foursquare2::Client)
      raise ArgumentError, "Client looks invalid"
    end
    @client.edit_venue(@venue_id, self.to_h)
  end
end
