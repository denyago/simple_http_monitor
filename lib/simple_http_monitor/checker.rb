require 'net/http'
require 'uri'

module SimpleHttpMonitor
  class Checker
    def self.check(url, timeout)
      uri     = URI.parse(url)
      request = Net::HTTP::Get.new(uri)

      begin
        result  = Net::HTTP.start(uri.host, uri.port) do |http|
          http.read_timeout = timeout
          http.request(request)
        end
      rescue Timeout::Error
        return CheckResult.new(uri: url, timeout: timeout)
      end

      CheckResult.new(uri: url, status: result.code)
    end
  end
end
