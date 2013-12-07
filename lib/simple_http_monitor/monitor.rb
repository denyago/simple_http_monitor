require 'logger'

module SimpleHttpMonitor
  ##
  # Class: Monitor
  #
  # In change of configuring HTTP monitoring subsystem,
  # performing check and saving of results/sending notifications.
  class Monitor

    attr_reader :logger, :store, :notifier, :checker

    # Check site for availability
    def check
      last_result = store.load(CheckResult) || CheckResult.new
      result      = CheckResult.new(checker.check)

      if result.failed?
        result.failed_try = last_result.failed_try.to_i + 1
      end

      logger.info result
      store.save  result

      notifier.notify(last_result, result)
    end

    private

    # Initializes new instance
    #
    # Params:
    #   - config {Hash} with options:
    #     - :url        {String} URL to monitor
    #     - :tries      {Array}  Set of fails before sending notification. Default: #{defaults[:tries]}
    #     - :timeout    {Integer} HTTP connection timeout in seconds
    #     - :work_dir   {String} Directory to persist results of work to
    #     - :ops_email  {String} Email to send notifications to
    #     - :from_email {String} Email to send notifictions from
    #     - :smtp_host  {String} Hostname of SMTP server
    #     - :smtp_user  {String} Username on SMTP server
    #     - :smtp_paswd {String} Password for SMTP server
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
