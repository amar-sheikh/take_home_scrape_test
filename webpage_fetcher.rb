require 'open-uri'
require './error_printer'

class WebpageFetcher
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def response
    @response ||= URI.open(@url).read
  end

  def base_url
    url.split('://')[1].split('/').first
  end
end
