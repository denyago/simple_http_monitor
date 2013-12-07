module SimpleHttpMonitor
  class Notifier
    def notify(results={})
      previous = results[:previous]
      current  = results[:current]

      if previous.failed_try.to_i < current.failed_try.to_i
        message_sender.send_failure_notification(current) if tries.include?(current.failed_try)
      end

      if previous.failed? && !current.failed?
        message_sender.send_back_online_notification(current) if tries.min <= previous.failed_try
      end
    end

    private

    attr_reader :message_sender, :tries

    def initialize(message_sender, tries)
      @message_sender = message_sender
      @tries          = tries
    end
  end
end
