module SimpleHttpMonitor

  Configuration = Struct.new(:email, :url, :tries, :timeout)

  class Notifier
    def self.notify(results={})
      previous = results[:previous]
      current  = results[:current]
      tries    = results[:tries]

      if previous.failed_try.to_i < current.failed_try.to_i
        Mailer.send_failure_notification if tries.include?(current.failed_try)
      end

      if previous.failed? && !current.failed?
        Mailer.send_back_online_notification if tries.min <= previous.failed_try
      end
    end
  end

  class Mailer
    def self.send_failure_notification
      puts 'TODO: Fire failure email!'
    end
    def self.send_back_online_notification
      puts 'TODO: Fire back online email!'
    end
  end
end

require "simple_http_monitor/version"
require "simple_http_monitor/monitor"
require "simple_http_monitor/store"
require "simple_http_monitor/checker"
require "simple_http_monitor/check_result"
