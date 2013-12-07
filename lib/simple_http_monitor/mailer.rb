require 'mail'

module SimpleHttpMonitor
  ##
  # Class: Mailer
  #
  # For sending email messages, related to results
  # of HTTP checks
  class Mailer

    # Templates of emails
    TEMPLATES = {
      failure: "Technical information:
  resaon of failure: {error_type};
  HTTP code: {http_code};
  connection timeout: {timeout};
  failed try #: {failed_try}.",
      back_online: "Technical information:
  HTTP code: {http_code}."
    }

    # Sends mail about HTTP check failure
    #
    # Params:
    #   - check_result {CheckResult} with result of HTTP check
    def send_failure_notification(check_result)
      deliver_message do |mail|
        mail.subject = "[HTTP Checker] Error on #{check_result.uri}"
        mail.body    = render_body(:failure, check_result)
      end
    end

    # Sends mail about HTTP check success, if site had failed checks
    #
    # Params:
    #   - check_result {CheckResult} with result of HTTP check
    def send_back_online_notification(check_result)
      deliver_message do |mail|
        mail.subject = "[HTTP Checker] Successfully back online #{check_result.uri}"
        mail.body    = render_body(:back_online, check_result)
      end
    end

    private

    def deliver_message
      mail = Mail.new(from: @from, to: @to)
      yield(mail)
      mail.delivery_method :smtp, address: @smtp_host,
                                  user_name: @smtp_user,
                                  password: @smtp_paswd
      mail.deliver
    end

    def render_body(template, check_result)
      case template
      when :failure then
        TEMPLATES[:failure].gsub('{error_type}', check_result.result.to_s).
                            gsub('{http_code}',  check_result.status.to_s).
                            gsub('{timeout}',    check_result.timeout.to_s).
                            gsub('{failed_try}', check_result.failed_try.to_s)
      when :back_online then
        TEMPLATES[:back_online].gsub('{http_code}', check_result.status.to_s)
      end
    end

    # Initializes new instance
    #
    # Params:
    #   - settings {Hash} of settings:
    #     - :from {Staring} email address to send mail from
    #     - :to   {String} email address to send mail to
    #     - :smtp_host {String} SMTP server hostname
    #     - :smtp_user {String} user account on SMTP server
    #     - :smtp_paswd {String} password for SMTP server
    def initialize(settings={})
      @from       = settings[:from]
      @to         = settings[:to]
      @smtp_host  = settings[:smtp_host]
      @smtp_user  = settings[:smtp_user]
      @smtp_paswd = settings[:smtp_paswd]
    end
  end
end
