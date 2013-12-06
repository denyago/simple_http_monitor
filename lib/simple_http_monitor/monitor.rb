require 'logger'

module SimpleHttpMonitor
  class Monitor

    attr_reader :configuration, :logger

    def check
      last_result = store.load(CheckResult) || CheckResult.new
      result = Checker.check(configuration.url, configuration.timeout)

      if result.failed?
        result.failed_try = last_result.failed_try.to_i + 1
      end

      logger.info result
      store.save  result

      Notifier.notify(previous: last_result, current: result,
                      tries: configuration.tries
                     )
    end

    private

    attr_reader :store

    def initialize(config={})
      @configuration = Configuration.new(config[:email], config[:url], config[:tries], config[:timeout])
      @logger        = Logger.new(STDOUT)
      @store         = Store.new(config[:work_dir])
    end
  end
end
