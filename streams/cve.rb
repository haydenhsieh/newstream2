require_relative 'stream'

class Cve < Stream
  #NVD CVE & CPE API
  require 'open-uri'
  require 'date'

  def get(web)
    @logger.debug("#{self.class.name} #{__method__}")
    now = Time.now
    #CVE
    if @config[:cve_url]
      params = {
        pubStartDate: (now.to_date << 3).to_time.iso8601,
        pubEndDate:   now.iso8601,
        keywordSearch: "printer"
      }
      uri = "#{@config[:cve_url]}?#{URI.encode_www_form(params)}"
      @logger.debug(uri)
      begin
      URI.open(uri) do |f|
        response = f.read
        @cve_response = JSON.parse(response) if response
      end
      rescue OpenURI::HTTPError => e
        @logger.error("Error cve open #{uri}: #{e.to_s}")
      end
    end

    #CPE
    if @config[:cpe_url]
      params = {
        lastModStartDate: (now.to_date << 3).to_time.iso8601,
        lastModEndDate:   now.iso8601,
        keywordSearch: "printer"
      }
      uri = "#{@config[:cpe_url]}?#{URI.encode_www_form(params)}"
      @logger.debug(uri)
      begin
      URI.open(uri) do |f|
        response = f.read
        @cpe_response = JSON.parse(response) if response
      end
      rescue OpenURI::HTTPError => e
        @logger.error("Error open cpe #{url}: #{e.to_s}")
      end
    end
  end

  def parse(web)
    feeds = []
    if @cve_response
      @cve_response["vulnerabilities"].each do |object|
        cve = object["cve"]
        if cve
          url   = nil
          title = cve["id"]
          date  = cve["published"]
          refs  = cve["references"]
          if refs.size > 0 && refs[0]["url"]
            url = refs[0]["url"]
          end

          feeds << {
            stream: self.class.name,
            title: "[CVE]#{title}",
            date: date.to_date,
            url: url
          }
        end
      end
    end

    if @cpe_response
      @cpe_response["products"].each do |object|
        cpe = object["cpe"]
        if cpe
          url = cpe["refs"][0]["ref"] if cpe["refs"] && cpe["refs"][0]["ref"]

          title_obj = cpe["titles"].select{|obj| obj["lang"] == "en"}.first
          if title_obj
            title = title_obj["title"]
          elsif title_obj[0]
            title = title_obj[0]["title"]
          else
            title = cpe["cpeName"]
          end
          date  = cpe["created"]

          feeds << {
            stream: self.class.name,
            title: "[CPE]#{title}",
            date: date.to_date,
            url: url
          }
        end
      end
    end

    return { feeds: feeds }
  end
end
