require 'httparty'
require 'api_cache'

class DiscogsApiWrapper

  include HTTParty

  attr_accessor :token

  HEADERS = {
    'User-Agent' => 'BrigntSoundApi/0.0.0'
  }

  API_CACHE_OPTIONS = {
    :cache => 3600,
    :valid => :forever,
    :period => 2,
    :timeout => 5,
    :fail => -1
  }

  base_uri 'https://api.discogs.com/'

  format :json

  def initialize(opts = {})
    @token = opts[:token]
  end

  def get_releases(artist_id, page = 1, per_page = 10)
    query = encoded_query({
      page: page,
      per_page: per_page,
      token: token
    })
    results = APICache.get("releases", API_CACHE_OPTIONS) do
      self.class.get(
        "/artists/#{artist_id}",
        headers: HEADERS,
        query: query
      )
    end
  end

  def search_for_artist(artist_name = '', page = 1, per_page = 10)
    query = encoded_query({
      artist: artist_name,
      page: page,
      per_page: per_page,
      token: token
    })
    results = APICache.get("artist", API_CACHE_OPTIONS) do
      self.class.get(
        "/database/search",
        headers: HEADERS,
        query: query
      )
    end
  end

  private

  def encoded_query(params)
    URI.encode_www_form(params)
  end
end
