require 'net/http'
require 'uri'

module SimpleHttpMonitor
  class Checker
    def check
      uri     = URI.parse(url)
      request = Net::HTTP::Get.new(uri)

      begin
        result  = Net::HTTP.start(uri.host, uri.port) do |http|
          http.read_timeout = timeout
          http.request(request)
        end
      rescue Timeout::Error
        return {uri: url, timeout: timeout}
      end

      {uri: url, status: result.code}
    end

    private

    attr_reader :url, :timeout

    def initialize(url, timeout)
      @url     = url
      @timeout = timeout
    end
  end
end
