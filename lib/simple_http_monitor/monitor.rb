require 'logger'

module SimpleHttpMonitor
  class Monitor

    attr_reader :logger, :store, :notifier, :checker

    def check
      last_result = store.load(CheckResult) || CheckResult.new
      result      = CheckResult.new(checker.check)

      if result.failed?
        result.failed_try = last_result.failed_try.to_i + 1
      end

      logger.info result
      store.save  result

      notifier.notify(previous: last_result, current: result)
    end

    private

    def initialize(config={})
      @logger        = Logger.new(STDOUT)
      @store         = Store.new(config[:work_dir])
      mailer         = Mailer.new(from: config[:from_email], to: config[:ops_email], smtp_host: config[:smtp_host],
                                  smtp_user: config[:smtp_user], smtp_paswd: config[:smtp_paswd])
      @notifier      = Notifier.new(mailer, config[:tries])
      @checker       = Checker.new(config[:url], config[:timeout])
    end
  end
end
