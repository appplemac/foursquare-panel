# This file is subject to the terms and conditions defined in
# file 'LICENSE.txt', which is part of this source code package.

module Helpers
  # @param [String] message A message to display as error
  def error(message)
    flash[:notice] = message
    redirect('/edit')
  end

  # @param [Fixnum] id The ID user to check
  def in_whitelist?(id)
    whitelist = [12277667]
    whitelist.include?(id)
  end

  def api_client_from_session
    if session[:token]
      Foursquare2::Client.new(:oauth_token => session[:token], :api_version => "20140205")
    else
      nil
    end
  end

  # @pre The user already has a token
  def check_su
    api_client = api_client_from_session
    redirect('/redirect') if api_client.nil?
    user = api_client.user('self')
    if user.superuser.nil? or user.superuser < 3
      unless in_whitelist?(user.id.to_i)
        redirect('/closed_beta')
      end
    end
  end

  def page_id_from_user_input(api_client, input)
    if input == input.to_i.to_s
      input
    else
      api_client.search_pages(:twitter => input).results[0].id
    end
  end

  def all_page_venues(api_client, page_id)
    venue_ids = []
    offset = 0
    data = api_client.page_venues(page_id, limit: 100,
                                  offset: offset).venues.items
    while data.size > 0
      data.each do |venue|
        venue_ids << venue.id
      end
      offset += 100
      data = api_client.page_venues(page_id, limit: 100,
                                    offset: offset).venues.items
    end
    venue_ids
  end
end
