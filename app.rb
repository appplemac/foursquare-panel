require 'sinatra'
require 'foursquare2'
require 'httparty'
require 'json'
require 'rack-flash'
require_relative 'venue'
require_relative 'form_object'
require_relative 'counter'

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
  @ids = params[:venues]["venue_id"].delete(" ").split(",")

  if @ids.empty?
    flash[:notice] = "You have provided no venues for edition"
    redirect('/edit')
  end

  @api_client = Foursquare2::Client.new(:oauth_token => session[:token])

  @counter = Counter.new
  @venues = FormObject.new(:ids => @ids, :common => @common).parse
  @venues.each do |venue|
    begin
      venue.edit!(@api_client)
      @counter.success!
    rescue Foursquare2::APIError => e
      flash[:notice] = e.message
      @counter.failure!
    end
  end

  redirect("/done/#{@counter.success}/#{@counter.failure}")
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
  # store the code in the session
  @code = params["code"]
  session[:token] = HTTParty.get("https://foursquare.com/oauth2/access_token",
              :query => {:client_id => settings.client_id,
                         :client_secret => settings.client_secret,
                         :grant_type => "authorization_code",
                         :redirect_uri => settings.redirect_uri,
                         :code => @code }).parsed_response["access_token"]
  redirect("/edit")
end
