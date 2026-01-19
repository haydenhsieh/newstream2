class Stream
  attr_reader :url

  def initialize(**kwargs)
    @url = kwargs[:url]
    @feed = {}
  end

  def parse
  end
end
