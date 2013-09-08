require 'sinatra'
require 'foursquare2'

enable :sessions

get '/' do
  redirect('/edit')
end

get '/edit' do
  unless session[:token]
    redirect('/redirect')
  end

  erb :edit
end

post '/edit' do
  if session[:token].empty?
    redirect('/edit')
  end
  @data = params[:data]

  @venues = @data["venue_id"].detete(" ").split(",")
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

    @venues.each do |venue|
      client.propose_venue_edit(venue, @options)
    end
  rescue APIError => e
    flash[:notice] = e.message
    redirect('/edit')
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
