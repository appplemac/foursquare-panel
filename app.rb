# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

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
set :session_secret, ENV['SESSION_SECRET']
set :client_id, ENV['4SQ_CLIENT_ID']
set :client_secret, ENV['4SQ_CLIENT_SECRET']
set :redirect_uri, ENV['4SQ_REDIRECT_URI']

$queue = Queue.new

workers = (1..3).map do
  Thread.new do
    while true
      venue = $queue.deq
      begin
        venue.edit!
      rescue Foursquare2::APIError => e
        puts e.inspect
      end
    end
  end
end

helpers do
  def error(message)
    flash[:notice] = message
    redirect('/edit')
  end

  def in_whitelist?(id)
    whitelist = [12277667]
    whitelist.include?(id)
  end

  def check_token
    unless session[:token]
      redirect('/redirect')
    end
  end

  def api_client_from_session
    check_token
    Foursquare2::Client.new(:oauth_token => session[:token])
  end

  def check_su
    api_client = api_client_from_session
    user = api_client.user("self")
    if user.superuser.nil? or user.superuser < 3
      unless in_whitelist?(user.id.to_i)
        redirect('/closed_beta')
      end
    end
  end

  def page_id_from_name(api_client, page_name)
    api_client.search_pages(:twitter => page_name).results[0].id
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
  check_su
  erb :edit
end

get '/queue' do
  @queue_size = $queue.size
  erb :queue
end

get '/closed_beta' do
  erb :closed_beta
end

post '/edit' do
  check_su

  @api_client = api_client_from_session

  # we add api client as a part of common data
  @common = params[:data].merge({:client => @api_client})
  if params[:venues]["source"] == "list"
    @ids = params[:venues]["venue_id"].delete(" ").split(",")
  else
    @page_id = params[:venues]["page_id"]
    if @page_id != @page_id.to_i.to_s
      # We are dealing with page name
      @page_id = page_id_from_name(@page_id, @api_client)
    end
    @ids = all_page_venues(@api_client, params[:venues]["page_id"])
  end

  if @ids.empty?
    error("You have provided no venues for edition")
  end

  if @ids.size > 10000
    error("You can't do more than 10000 API requests per hour")
  end

  @venues = FormObject.new(:ids => @ids, :common => @common).parse
  @venues.each do |venue|
    $queue << venue
  end

  redirect("/done")
end

get '/done' do
  erb :done
end

get '/redirect' do
  @uri = "https://foursquare.com/oauth2/authenticate?client_id=#{ENV['4SQ_CLIENT_ID']}\
            &response_type=code&redirect_uri=#{ENV['4SQ_REDIRECT_URI']}".delete(" ")
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

get "/justrendertheviewplease" do
  erb :edit
end
