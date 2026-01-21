#! /usr/bin/env ruby

class String
  def camelize
    self.split(/[_ \-]/).map(&:capitalize).join
  end
end

if __FILE__ == $PROGRAM_NAME
  exit 0 if ARGV.size == 0
  dir=File.expand_path(File.join(File.dirname($PROGRAM_NAME), ".."))
  require_relative File.join(dir, "streams/stream")
  require 'selenium-webdriver'
  require 'json'
  require 'optparse'
  options = { config: "config.json" }
  OptionParser.new do |opt|
    opt.on("-c", "--config CONF_FILE")
  end.parse!(into: options)

  config = JSON.load_file(File.join(dir, options[:config]), symbolize_names: true)
  stream_config = config[:streams]

  options = Selenium::WebDriver::Options.firefox
  options.args << "--headless=new"
  web = Selenium::WebDriver.for :firefox, options: options

  ARGV.each do |name|
    target = stream_config[name.to_sym]
    if target
      require_relative File.join(dir, "streams/#{name}")
      stream = Object.const_get(name.camelize).new(**target)
      if stream.url
        web.get(stream.url)
      else
        stream.get(web)
      end
      result = stream.parse(web)
      puts result
      web.quit
    end
  end
end
