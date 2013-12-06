module SimpleHttpMonitor
  class CheckResult
    attr_reader :uri, :status, :timeout
    attr_accessor :failed_try

    FAIL_CODES = 400..599

    def inspect
      "CheckResult: #{uri} status: #{status}"
    end

    def failed?
      result != :ok
    end

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

    def initialize(result={})
      @uri    = result[:uri]
      @status = result[:status].to_i
      @timeout    = result[:timeout]
      @failed_try = result[:failed_try]
      @failed_try = @failed_try.to_i unless @failed_try.nil?
    end
  end
end
