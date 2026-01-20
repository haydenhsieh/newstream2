require_relative 'stream'

class Rtm < Stream
  def parse(web)
    feeds = []
    titles = web.find_elements(xpath: "//div[contains(@class, 'post--item')]//div[contains(@class, 'post--info')]//div[@class='title']").map(&:text)
    dates  = web.find_elements(xpath: "//div[contains(@class, 'post--item')]//div[contains(@class, 'post--info')]//ul[contains(@class, 'nav')]/li[1]").map(&:text)
    dates.zip(titles).each do |d, t|
      feeds << {
        streams: self.class.name,
        title: t,
        date: d,
        url: @url
      }
    end
    return { feeds: feeds }
  end
end
