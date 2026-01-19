#! /usr/bin/env ruby

class String
  def camelize
    self.split(/[_ \-]/).map(&:capitalize).join
  end
end

if __FILE__ == $PROGRAM_NAME
  exit 0 if ARGV.size == 0
  require_relative '../streams/stream'
  require 'selenium-webdriver'
  require 'json'

  config = JSON.load_file("../config.json")
  stream_config = config["streams"]

  options = Selenium::WebDriver::Options.chrome
  options.args << '--headless=new'
  web = Selenium::WebDriver.for :chrome, options: options

  ARGV.each do |name|
    target = stream_config[name]
    if target
      require_relative "../streams/#{name}"
      stream = Object.const_get(name.camelize).new(url: target["url"])
      web.get(stream.url)
      result = stream.parse(web)
      puts result
      web.quit
    end
  end
end
