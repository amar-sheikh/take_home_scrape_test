require 'optparse'
require './page_saver'
require './metadata_printer'
require 'pry'

class Processor
  def process
    options
    ARGV.each do |url|
      options[:metadata] ? MetadataPrinter.new(url).print : PageSaver.new(url).save

    rescue => error
      ErrorPrinter.print("#{url}: #{error.message}")
      next
    end
  end

  def options
    return @options if defined? @options

    @options = {}
    OptionParser.new do |opts|
      opts.on("--metadata") { |v| @options[:metadata] = v }
    end.parse!
    @options
  end
end

Processor.new.process
