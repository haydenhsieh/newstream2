require_relative 'stream'

class CanonSatera < Stream
  def parse(web)
    puts "Parsing #{@url} by #{web.inspect}"
  end
end
