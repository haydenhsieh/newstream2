require_relative 'stream'

class DsJapan < Stream
  def parse(web)
    feeds = []
    dates  = web.find_elements(xpath: "//ul[@class='newsHolder__newsList']//dl/dt").map(&:text)
    titles = web.find_elements(xpath: "//ul[@class='newsHolder__newsList']//dd").map(&:text)
    dates.zip(titles) do |d, t|
      feeds << {
        stream: self.class.name,
        title: t.strip,
        date: d.to_date,
        url: @url
      }
    end
    return { feeds: feeds }
  end
end
