module SimpleHttpMonitor
  ##
  # Class: CheckResult
  #
  # Model for handling results of HTTP check
  class CheckResult
    attr_reader :uri, :status, :timeout
    attr_accessor :failed_try

    FAIL_CODES = 400..599

    # Returns {String} with text representation of self
    def inspect
      "CheckResult: #{uri} status: #{status}".tap do |str|
        if failed?
          str << " timeout: #{timeout}" if result == :connection_timeout_error
          str << " fail: #{result}"
          str << " try: #{failed_try.to_i}"
        end
      end
    end

    # Returns {Boolean} if check is failed
    def failed?
      result != :ok
    end

    # Returns {Symbol} with result of check
    def result
      if @timeout.to_i > 0
        :connection_timeout_error
      elsif FAIL_CODES.include?(status)
        :http_code_error
      else
        :ok
      end
    end

    private

    # Initializes new instance
    #
    # Params:
    #   - result {Hash} of attributes:
    #     - :uri {String} with URI that has been cheked
    #     - :status {String} with HTTP status code
    #     - :timeout {Integer} with HTTP connection timeout reached
    #     - :failed_try {Integer} with failed try number
    def initialize(result={})
      @uri    = result[:uri]
      @status = result[:status].to_i
      @timeout    = result[:timeout]
      @failed_try = result[:failed_try]
      @failed_try = @failed_try.to_i unless @failed_try.nil?
    end
  end
end
