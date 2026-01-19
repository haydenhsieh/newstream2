#! /usr/bin/env ruby

require 'selenium-webdriver'
require 'json'
require 'sequel'

class String
  def to_stream_classname
    self.split("_").map(&:capitalize).join
  end
end

class NewStream
  def initialize
    load_webdriver
    load_streams
    load_db
  end

  def load_webdriver
    @options = Selenium::WebDriver::Options.chrome
    @options.args << '--headless=new'
    @web = Selenium::WebDriver.for :chrome, options: @options
  end

  def load_streams
    dir="streams"
    @stream_names = []
    @streams = []
    Dir.glob("#{dir}/*.rb").each do |name|
      require_relative name
      if File.basename(name) != "stream.rb"
        @stream_names << File.basename(name).gsub(/.rb$/,"")
      end
    end

    @config = JSON.load_file("config.json")
    stream_config = @config["streams"]
    @stream_names.each do |name|
      if stream_config[name] && ! stream_config[name]["disabled"]
        @streams << Object.const_get(name.to_stream_classname).new(url:stream_config[name]["url"])
      end
    end
  end

  def load_db
    Sequel.connect("sqlite://#{@config["db"]}")
    if Sequel::Model.db.tables.size == 0
      require_relative 'scheme'
    end

    Dir.glob("models/*.rb").each do |name|
      require_relative name
    end
  end

  def run
    @streams.each do |stream|
      begin
        @web.get(stream.url)

        # feeds in json
        feeds = stream.parse(@web)

        # TODO save to db
      rescue => e
        # TODO Err Feed here
        p e
      end
    end

    # Create RSS feed
  end
end

def main
  NewStream.new.run
end

main if __FILE__ == $PROGRAM_NAME
