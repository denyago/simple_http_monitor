require 'spec_helper'

describe SimpleHttpMonitor::Mailer do
  subject { described_class.new(settings) }
  let(:settings)  do
    {
      from: 'server@example.com',
      to:   'ops@example.com'
    }
  end
  let(:check_uri) { 'http://example.com' }
  let(:check_result) { SimpleHttpMonitor::CheckResult.new(result_settings) }

  before do
    Mail::Message.any_instance.stub(:delivery_method).with(:smtp, kind_of(Hash))
    Mail::Message.any_instance.stub(:delivery_method).with().and_call_original
  end

  describe '.send_failure_notification' do
    let(:result_settings) do
      {
        uri:        check_uri,
        status:     check_status,
        failed_try: check_failed_try,
        timeout:    check_timeout
      }
    end
    let(:check_status)     { 500 }
    let(:check_failed_try) { 128 }
    let(:check_timeout)    { 10 }

    before do
      subject.send_failure_notification(check_result)
    end

    it 'sends email' do
      expect(Mail::TestMailer.deliveries.size).to eq(1)
    end
    it 'contains information on last check result' do
      message = Mail::TestMailer.deliveries.first

      expect(message.subject).to eq("[HTTP Checker] Error on #{check_uri}")
      expect(message.body.decoded).to include("connection_timeout_error")
      expect(message.body.decoded).to include(check_status.to_s)
      expect(message.body.decoded).to include(check_timeout.to_s)
      expect(message.body.decoded).to include(check_failed_try.to_s)
    end
  end

  describe '.send_back_online_notification' do
    let(:result_settings) do
      {
        uri:    check_uri,
        status: check_status,
      }
    end
    let(:check_status) { 200 }

    before do
      subject.send_back_online_notification(check_result)
    end

    it 'sends mail' do
      expect(Mail::TestMailer.deliveries.size).to eq(1)
    end
    it 'contains information on last check result' do
      message = Mail::TestMailer.deliveries.first

      expect(message.subject).to eq("[HTTP Checker] Successfully back online #{check_uri}")
      expect(message.body.decoded).to include(check_status.to_s)
    end
  end
end
