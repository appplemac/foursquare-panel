# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

require 'sinatra'
require 'thread'
require 'foursquare2'
require 'httparty'
require 'json'
require 'rack-flash'
require 'uri'
require_relative 'venue'
require_relative 'form_object'
require_relative 'helpers'

use Rack::Session::Pool, :expire_after => 2592000
use Rack::Flash
set :session_secret, ENV['SESSION_SECRET']

helpers do
  include Helpers
end

before do
  pass if %w(closed_beta justrendertheviewplease auth redirect).include?(
      request.path_info.split('/')[1])
  check_su
end

$queue = Queue.new

Thread.abort_on_exception = false
workers = (1..3).map do
  Thread.new do
    while true
      venue = $queue.deq
      $stderr.puts "DEQUEUE ", venue.inspect
      begin
        venue.edit!
      rescue => e
        flash[:notice] = e.backtrace
      end
    end
  end
end

get('/') { redirect('/edit') }
get('/edit') { erb :edit }
get('/done') { erb :done }
get('/justrendertheviewplease') { erb :edit }
get('/closed_beta') { erb :closed_beta }

get '/queue' do
  @queue_size = $queue.size
  erb :queue
end

get '/redirect' do
  @uri = URI('https://foursquare.com/oauth2/authenticate')
  @uri.query = URI.encode_www_form({:client_id => ENV['4SQ_CLIENT_ID'],
                                    :response_type => 'code',
                                    :redirect_uri => ENV['4SQ_REDIRECT_URI']})
  redirect(@uri.to_s)
end

get '/auth?' do
  # store the code in the session
  @code = params['code']
  session[:token] = HTTParty.get('https://foursquare.com/oauth2/access_token',
                                 :query => {:client_id => ENV['4SQ_CLIENT_ID'],
                                            :client_secret => ENV['4SQ_CLIENT_SECRET'],
                                            :grant_type => 'authorization_code',
                                            :redirect_uri => ENV['4SQ_REDIRECT_URI'],
                                            :code => @code }).parsed_response['access_token']
  redirect('/edit')
end

post '/edit' do
  @api_client = api_client_from_session

  @common = params[:data]
  if params[:venues]['source'] == 'list'
    @ids = params[:venues]['venue_id'].delete(' ').split(',')
  else
    @page_id = page_id_from_user_input(@api_client, params[:venues]['page_id'])
    @ids = all_page_venues(@api_client, @page_id)
  end

  error('You have provided no venues for edition') if @ids.empty?
  error("You can't do more than 10000 API requests per hour") if @ids.size > 10000

  @venues = FormObject.new(@api_client, @ids, @common).parse
  @venues.each { |venue| $queue << venue }

  redirect('/done')
end
