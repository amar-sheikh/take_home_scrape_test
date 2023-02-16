require './webpage_fetcher'

class PageSaver
  attr_reader :url, :page_fetcher

  def initialize(url)
    @url = url
    @page_fetcher = WebpageFetcher.new url
  end

  def save
    File.write("#{page_fetcher.base_url}.html", page_fetcher.response)
  end
end
