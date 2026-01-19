require_relative 'stream'

class Ricoh < Stream
  def parse(web)
    dates    = web.find_elements(xpath: "//h2[text()='新着情報']/following::a[@class='c-news__item']/div[@class='c-news__date']")
    contents = web.find_elements(xpath: "//h2[text()='新着情報']/following::a[@class='c-news__item']/div[@class='c-news__text']")
    feeds = []

    dates.zip(contents).each do |date, content|
      feeds << {
        stream: self.class.name,
        date: date.text.to_date,
        title: content.text.strip,
        url: @url
      }
    end

    return {feeds: feeds}
  end
end
