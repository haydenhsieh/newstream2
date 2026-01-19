#! /usr/bin/env ruby

require 'selenium-webdriver'
require 'json'
require 'sequel'
require 'rss'

class String
  def to_stream_classname
    self.split("_").map(&:capitalize).join
  end
end

class NewStream
  require 'logger'

  def initialize
    @config = JSON.load_file("config.json")
    @logger = Logger.new(@config["log"])
    @logger.level = ENV["NS2_LOG_LEVEL"].to_i || Logger::ERROR
    @logger.debug("Config: #{@config.inspect}")
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

    stream_config = @config["streams"]
    @stream_names.each do |name|
      @logger.debug("load stream #{name}")
      if stream_config[name] && ! stream_config[name]["disabled"]
        @streams << Object.const_get(name.to_stream_classname).new(url:stream_config[name]["url"], logger:@logger)
      end
    end
  end

  def load_db
    Sequel.connect("sqlite://#{@config["db"]}")
    @logger.debug("DB #{@config["db"]} connected")
    if Sequel::Model.db.tables.size == 0
      @logger.debug("Create table")
      require_relative 'scheme'
    end

    Dir.glob("models/*.rb").each do |name|
      @logger.debug("load model #{name}")
      require_relative name
    end
  end

  def save_feeds(feeds)
    feeds.each do |feed|
      begin
        Feed.create(feed)
      rescue Sequel::ValidationFailed
        # skip duplicated
      end
    end
  end

  def create_rss(feeds)
    RSS::Maker.make("2.0") do |maker|
      maker.channel.author = "hayden"
      maker.channel.updated = Time.now.to_s
      maker.channel.description = "Printer News Channel"
      maker.channel.title   = "Printer News"
      maker.channel.link    = "http://localhost"

      feeds.each do |feed|
        maker.items.new_item do |item|
          item.link  = feed.url
          item.title = "[#{feed.stream}] #{feed.title}"
          item.updated = feed.date
        end
      end
    end
  end

  def run
    @streams.each do |stream|
      feeds = nil
      begin
        @web.get(stream.url)

        # feeds in json
        feeds = stream.parse(@web)
      rescue => e
        save_feeds({ stream: stream.class.name, date: Date.today,
                     title: e.inspect })
      else
        if feeds[:error]
          save_feeds(feeds[:error])
        else
          save_feeds(feeds[:feeds])
        end
      end
    end

    # Create RSS feed
    new_feeds = Feed.where(state: "new")
    rss_doc = create_rss(new_feeds)
    begin
      File.open(@config["rss"], "w"){|fd| fd.write(rss_doc)}
    rescue => e
      @logger.error(e.to_s)
    else
      new_feeds.update(state: "read")
    end
  end
end

def main
  NewStream.new.run
end

main if __FILE__ == $PROGRAM_NAME
