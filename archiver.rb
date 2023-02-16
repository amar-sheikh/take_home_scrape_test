require 'fileutils'

class Archiver
  attr_reader :url, :page_fetcher, :doc
  ASSET_TAGS = {
    js: 'script',
    css: 'link',
    img: 'img'
  }

  ATTRIBUTES = {
    img: 'src',
    css: 'href',
    js: 'src'
  }

  def initialize(url)
    @url = url
    @page_fetcher = WebpageFetcher.new(url)
    @doc = @page_fetcher.doc
  end

  def archive
    create_directory_structure
    download_and_modify_assets
    save_html_file
  end

  private

  def download_and_modify_assets
    ASSET_TAGS.each do |asset, tag_name|
      download_and_modify_tags(asset, tag_name)
    end
  end

  def download_and_modify_tags(asset, tag_name)
    attribute = ATTRIBUTES[asset]
    tags = doc.css("#{tag_name}[#{attribute}]")
    tags.each do |tag|
      download_asset_file(tag[attribute], asset)
      tag[attribute] = local_file_path(tag[attribute], asset)

    rescue Errno::ENOENT, OpenURI::HTTPError
      next
    end
  end

  def download_asset_file(src, asset)
    file = WebpageFetcher.new(absolute_path src).response
    File.write(local_file_path(src, asset), file)
  end

  def save_html_file
    PageSaver.new(url, doc.to_html).save
  end

  def create_directory_structure
    FileUtils.rm_rf(assets_base_directory) if Dir.exists? assets_base_directory
    FileUtils.mkdir_p(
      [ "#{assets_base_directory}/js",
        "#{assets_base_directory}/css",
        "#{assets_base_directory}/img" ]
    )
  end

  def modify_tag(tag, attr, filename)
    tag[attr] = filename
  end

  def local_file_path(src, type)
    [assets_base_directory, type, local_file_name(src)].join('/')
  end

  def local_file_name(src)
    src.split('/').last.split('?').first
  end

  def assets_base_directory
    "#{page_fetcher.base_url}-files"
  end

  def absolute_path(path)
    return path unless(path[0] == '/')

    "https://#{page_fetcher.base_url + path}"
  end
end
