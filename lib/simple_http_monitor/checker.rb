require 'net/http'
require 'uri'

module SimpleHttpMonitor
  ##
  # Class: Checker
  #
  # Does actual HTTP checks.
  class Checker

    # Checks site url over HTTP
    #
    # Retirns {Hash} with check results. Including :url, :timeout, :status
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

    # Initializes new instance
    #
    # Params:
    #   - url {String} to check
    #   - timeout {Integer} of HTTP request in seconds
    def initialize(url, timeout)
      @url     = url
      @timeout = timeout
    end
  end
end
