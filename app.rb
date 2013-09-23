require 'sinatra'
require 'foursquare2'
require 'httparty'
require 'json'
require 'rack-flash'
require_relative 'venue'

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
  @common = params[:data]
  @venues = params[:venues]["venue_id"].delete(" ").split(",")

  if @venues.empty?
    flash[:notice] = "You have provided no venues for edition"
    redirect('/edit')
  end

  @venues.each do

  @counter = {:success => 0, :fail => 0}

  begin
    client = Foursquare2::Client.new(:oauth_token => session[:token])

    @venues.each do |venue|
      client.propose_venue_edit(venue, @options)
      @counter[:success] += 1
    end
  rescue Foursquare2::APIError => e
    @counter[:fail] += 1
    flash[:notice] = e.message
  end
  redirect("/done/#{@counter[:success]}/#{@counter[:fail]}")
end

get '/done/:success/:fail' do
  @success = params[:success]
  @fail = params[:fail]
  erb :done
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
