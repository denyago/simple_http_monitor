module SimpleHttpMonitor
  ##
  # Class: Notifier
  #
  # Contains rules to notify in different situations
  # depending on current and last check results.
  class Notifier
    # Notify if results match any notification rules.
    #
    # Params:
    #   - previous {CheckResult} result of check
    #   - current  {CheckResult} of check
    def notify(previous, current)
      if previous.failed_try.to_i < current.failed_try.to_i
        message_sender.send_failure_notification(current) if tries.include?(current.failed_try)
      end

      if previous.failed? && !current.failed?
        message_sender.send_back_online_notification(current) if tries.min <= previous.failed_try
      end
    end

    private

    attr_reader :message_sender, :tries

    # Initializes new instance
    #
    # Params:
    #   - message_sender {Mailer} to send notifications by
    #   - tries {Array} with numbers of failed tries to send notifications on
    def initialize(message_sender, tries)
      @message_sender = message_sender
      @tries          = tries
    end
  end
end
