require 'sinatra'
require 'foursquare2'

enable :sessions

get '/edit' do
  erb :edit
end

post '/edit' do
  unless session[:token]
    redirect("/redirect")
  end

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

  @venues = @data["venue_id"].detete(" ").split(",")

  raise(ArgumentError, "No venues provided") if @venues.empty?
  raise(ArgumentError, "Invalid token") if session[:token].empty?

  client = Foursquare2::Client.new(:oauth_token => session[:token])

  @venues.each do |venue|
    client.propose_venue_edit(venue, options)
  end

end

get '/redirect' do
  uri = "https://foursquare.com/oauth2/authenticate?client_id=RD3AK4RFSBHIA\
            K40QJZMRMLJJX5BZMP2BNORXODPFT3MHRXK&response_type=token&redirect_u\
            ri=http://panel.alexey.ch/auth".delete" "
  redirect(uri)
end

get '/auth/:token' do
  session[:token] = params[:token].delete("#")
  redirect("/edit")
end
