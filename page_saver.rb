require './webpage_fetcher'

class PageSaver
  attr_reader :url, :page_fetcher, :page

  def initialize(url, page = nil)
    @url = url
    @page = page
    @page_fetcher = WebpageFetcher.new url
  end

  def save
    File.write("#{page_fetcher.base_url}.html", page || page_fetcher.response)
  end
end
