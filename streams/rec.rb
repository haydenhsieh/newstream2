require_relative 'stream'

class Rec < Stream
  def parse(web)
    feeds = []
    #TODO
    # dates  = web.find_elements(xpath: "//ul[@class='newsHolder__newsList']//dl/dt").map(&:text)
    # titles = web.find_elements(xpath: "//ul[@class='newsHolder__newsList']//dd").map(&:text)
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
