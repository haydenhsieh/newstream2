
class String
  require 'date'

  def to_date
    case self
    when /((?<year>[0-9]+)年)?(?<month>[0-9]+)月(?<day>[0-9]+)日/
      year  = ($~[:year] || Date.today.year).to_i
      month = $~[:month].to_i
      day   = $~[:day].to_i
      return Date.new(year, month, day)
    else
      return Date.parse(self)
    end
  end

end

class Stream
  require 'logger'
  attr_reader :url

  def initialize(**kwargs)
    @url = kwargs[:url]
    @feed = {}
    @logger = kwargs[:logger] || Logger.new($stdout)
    @config = kwargs
  end

  def parse
  end
end
