require_relative 'stream'

class Nec < Stream
  def parse(web)
    feeds = []
    dates  = web.find_elements(xpath: "//div[@class='mod-list-news of-type-02']//div[@class='row']/dt").map(&:text)
    titles = web.find_elements(xpath: "//div[@class='mod-list-news of-type-02']//div[@class='row']/dd").map(&:text)
    dates.zip(titles).each do |d, t|
      feeds << {
        stream: self.class.name,
        title: t,
        date:  d.to_date,
        url:  @url
      }
    end
    return {feeds: feeds}
  end
end
