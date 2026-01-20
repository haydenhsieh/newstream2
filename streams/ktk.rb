require_relative 'stream'

class Ktk < Stream
  def parse(web)
    feeds = []
    dates = web.find_elements(xpath: "//div[contains(@class,'mainContents')]/dl/dt")
    _dates = web.execute_script('
      for(i=0;i<arguments.length;i++){
        arguments[i].removeChild(arguments[i].lastChild);
      }
      return arguments;', *dates)
    dates  = _dates.map(&:text)
    titles = web.find_elements(xpath: "//div[contains(@class,'mainContents')]/dl/dd/a").map(&:text)
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
