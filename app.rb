require 'sinatra'
require 'foursquare2'
require 'httparty'
require 'json'
require 'rack-flash'

use Rack::Session::Pool, :expire_after => 2592000
use Rack::Flash
set :session_secret, 'xxKzkWJdVBUTgMgiVj'
set :client_id, 'RD3AK4RFSBHIAK40QJZMRMLJJX5BZMP2BNORXODPFT3MHRXK'
set :client_secret, '3KRO5V4STOZZTSMHML4PSVN1HJ03WAIGTFR4SUB2FPVRGIRK'
set :redirect_uri, 'http://panel.alexey.ch/auth'

get '/' do
  redirect('/edit')
end

get '/edit' do
  if session[:token].nil?
    redirect('/redirect')
  end

  @token = session[:token]
  erb :edit
end

post '/edit' do
  unless session[:token]
    redirect('/edit')
  end
  @data = params[:data]

  @venues = @data["venue_id"].delete(" ").split(",")
  if @venues.empty?
    flash[:notice] = "You have provided no venues for edition"
    redirect('/edit')
  end

  @options = {}
  @options[:name] = @data["name"]
  @options[:city] = @data["city"]
  @options[:state] = @data["state"]
  @options[:phone] = @data["phone"]
  @options[:primaryCategoryId] = @data["cat"]
  @options.reject! {|_,value| value.empty?}

  begin
    client = Foursquare2::Client.new(:oauth_token => session[:token])
    puts client.inspect

    @venues.each do |venue|
      client.propose_venue_edit(venue, @options)
    end
  rescue Foursquare2::APIError => e
    flash[:notice] = e.message
  end
end

get '/redirect' do
  @uri = "https://foursquare.com/oauth2/authenticate?client_id=#{settings.client_id}\
            &response_type=code&redirect_uri=#{settings.redirect_uri}".delete(" ")
  redirect(@uri)
end

get '/auth?' do
  @code = params["code"]
  @token = HTTParty.get("https://foursquare.com/oauth2/access_token",
              :query => {:client_id => settings.client_id,
                         :client_secret => settings.client_secret,
                         :grant_type => "authorization_code",
                         :redirect_uri => settings.redirect_uri,
                         :code => @code }).parsed_response["access_token"]
  session[:token] = @token
  redirect("/edit")
end
