require_relative 'stream'

class Graphic < Stream
  def parse(web)
    feeds = []
    #
    dates  = web.find_elements(xpath: "//ul[@id='news-tab-list__panel--all']//time").map(&:text)
    titles = web.find_elements(xpath: "//ul[@id='news-tab-list__panel--all']//h3").map(&:text)
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
