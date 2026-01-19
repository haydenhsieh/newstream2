require_relative 'stream'

class Fujifilm < Stream
  def parse(web)
    feeds = []
    dates    = web.find_elements(xpath: "//ul[contains(@class,'m-news-list')]//div[@class='m-news-list__date']")
    contents = web.find_elements(xpath: "//ul[contains(@class,'m-news-list')]//p[@class='m-news-list__text']")
    dates.zip(contents).each do |d, c|
      feeds << {
        stream: self.class.name,
        date: d.text.to_date,
        title: c.text,
        url: @url
      }
    end
    return { feeds: feeds }
  end
end
