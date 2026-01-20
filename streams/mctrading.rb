require_relative 'stream'

class Mctrading < Stream
  def parse(web)
    feeds = []
    dates = web.find_elements(xpath: "//span[contains(@class, 'post-metadata__date')]").map(&:text)
    titles = web.find_elements(xpath: "//div[contains(@data-hook, 'post-title')]")
    dates.zip(titles).each do |d, t|
      feeds << {
        stream: self.class.name,
        title: t,
        date: d.to_date,
        url: @url
      }
    end
    return {feeds: feeds}
  end
end
