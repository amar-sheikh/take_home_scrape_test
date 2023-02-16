require 'fileutils'

class Archiver
  attr_reader :url, :page_fetcher, :page_saver
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
    @page_saver = PageSaver.new(url)
  end

  def archive
    make_asset_directories
    download_and_modify_assets
    save_html_file
  end

  private

  def download_and_modify_assets
    ASSET_TAGS.each do |asset, tag_name|
      if(asset == 'css')
        css_tag_identifier = 'type=text/css'
        download_and_modify_tags(asset, tag_name, css_tag_identifier)
      else
        download_and_modify_tags(asset, tag_name)
      end
    end
  end

  def download_and_modify_tags(asset, tag_name, identifier = nil)
    attribute = ATTRIBUTES[asset]
    tags = doc.css("#{tag_name}[#{identifier || attribute}]")
    tags.each do |tag|
      file = WebpageFetcher.new(tag[attribute]).response
      save_locally(file, tag[attribute], asset)
      modify_tag(tag, attribute, local_file_path(tag[attribute], asset))

    rescue Errno::ENOENT
      next
    end
  end

  def save_html_file
    page_saver.new(url, doc.html).save
  end

  def save_locally(file, src, type)
    filename = local_file_path(src, type)
    File.write(filename, file)
  end

  def make_asset_directories
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
    [assets_base_directory, type, local_file_name(src, type)].join('/')
  end

  def local_file_name(src, type)
    type = nil if type == :img
    [src.split('/').last.split('?').first, type].compact.join('.')
  end

  def assets_base_directory
    "#{page_fetcher.base_url}-files"
  end

  def doc
    page_fetcher.doc
  end
end
