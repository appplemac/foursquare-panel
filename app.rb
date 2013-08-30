require 'sinatra'
require 'foursquare2'

enable :sessions

get '/edit' do
  erb :edit
end

post '/edit' do
  @data = params[:data]

  options = {}
  options[:name] = @data["name"]
  options[:address] = @data["address"]
  options[:crossStreet] = @data["crossStreet"]
  options[:city] = @data["city"]
  options[:state] = @data["state"]
  options[:zip] = @data["zip"]
  options[:phone] = @data["phone"]
  options[:ll] = @data["ll"]
  options[:primaryCategoryId] = @data["primaryCategoryId"]

  options.reject! {|k,_| options[k].empty?}

  client = Foursquare2::Client.new(:oauth_token => @data["oauth"])
  client.propose_venue_edit(@data["venue_id"], options)

end
