require 'sinatra'
require 'thread'
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
Thread.abort_on_exception = true

queue = Queue.new

workers = (1..3).map do
  Thread.new do
    venue = queue.deq
    begin
      venue.edit!
    rescue Foursquare2::APIException => e
      # TODO: do something with e
    end
  end
end

helpers do
  def error(message)
    flash[:notice] = message
    redirect('/edit')
  end

  def check_token
    unless session[:token]
      redirect('/redirect')
    end
  end

  def all_page_venues(api_client, page_id)
    venue_ids = []
    offset = 0
    data = api_client.page_venues(page_id, limit: 100,
                            offset: offset).items
    while data.size > 0
      data.each do |venue|
        venue_ids << venue.id
      end
      offset += 100
      data = api_client.page_venues(page_id, limit: 100,
                            offset: offset).items
    end
    venue_ids
  end
end

get '/' do
  redirect('/edit')
end

get '/edit' do
  check_token
  erb :edit
end

get '/queue' do
  queue.size
end

post '/edit' do
  check_token

  @api_client = Foursquare2::Client.new(:oauth_token => session[:token])

  # we add api client as a part of common data
  @common = params[:data].merge({:client => @api_client})
  if params[:venues]["source"] == "list"
    @ids = params[:venues]["venue_id"].delete(" ").split(",")
  else
    @ids = all_page_venues(@api_client, params[:venues]["page_id"])
  end

  if @ids.empty?
    error("You have provided no venues for edition")
  end

  if @ids.size > 500
    error("You can't do more than 500 API requests per hour")
  end

  @venues = FormObject.new(:ids => @ids, :common => @common).parse
  @venues.each do |venue|
    queue << venue
  end

  # TODO
  redirect("/done/?/?")
end

get '/done/:success/:failure' do
  @success = params[:success]
  @failure = params[:fail]
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
