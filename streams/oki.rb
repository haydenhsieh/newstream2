require_relative 'stream'

class Oki< Stream
  def parse(web)
    feeds = []
    titles = web.find_elements(xpath: "//ul[contains(@class, 'list-news-thumbnail')]//div[contains(@class, 'list-news-thumbnail__')]/p")
    dates  = web.find_elements(xpath: "//ul[contains(@class, 'list-news-thumbnail')]//time[contains(@class, 'date')]")
    titles = titles.map(&:text)
    dates  = dates.map{|e| e["datetime"]}
    dates.zip(titles).each do |d, t|
      feeds << {
        stream: self.class.name,
        title: t,
        date: d,
        url: @url
      }
    end
    return { feeds: feeds }
  end
end
