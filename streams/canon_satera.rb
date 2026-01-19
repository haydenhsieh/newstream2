require_relative 'stream'

class CanonSatera < Stream
  def parse(web)
    puts "Parsing #{@url} by #{web.inspect}"
    dates   = web.find_elements(xpath: "//h2/span[text()='新着情報']/following::div[@class='mod-list-news']//div[@class='state']/span[@class='date']")
    contents = web.find_elements(xpath: "//h2/span[text()='新着情報']/following::div[@class='mod-list-news']//div[@class='summary']")
    feeds = []

    if dates.size == contents.size
      dates.zip(contents).each do |date, content|
        #TODO Enhancing, Url may not exist in all sites, use current streams url for all feeds, customize url in the future
        feeds << { stream: self.class.name, date: date.text.strip.to_date, title: content.text.strip, url: @url }
      end
    else
      return { error: {stream: self.class.name, date: date.today, title: "Parse Error", url: @url} }
    end
    return {feeds: feeds}
  end
end
