require 'spec_helper'

describe SimpleHttpMonitor::Monitor do
  let(:email)    { 'ors@example.com' }
  let(:url)      { 'http://example.com' }
  let(:tries)    { [2, 10, 50, 100, 500] }
  let(:work_dir) { STORE_DIR }
  let(:timeout)  { 1 }

  describe '.initialize' do
    subject     { described_class }

    it 'sets configuration valiable' do
      monitor = subject.new({
        email:    email,
        url:      url,
        tries:    tries,
        work_dir: work_dir
      })

      expect(monitor.configuration).to be_kind_of(SimpleHttpMonitor::Configuration)
    end
  end

  describe '.check' do
    subject     { described_class.new(config) }
    let(:config) do
      {
        email: email,
        url:   url,
        tries: tries,
        max_timeout: timeout,
        work_dir:    work_dir
      }
    end

    before do
      FakeWeb.register_uri(:get, url, body: '')
    end

    it 'requests a pre-configured URL' do
      subject.check
      expect(FakeWeb.last_request).to_not be_nil
      expect(FakeWeb.last_request.uri.to_s).to eq(url)
    end
    it 'logs last check result' do
      expect(subject.logger).to receive(:info).with(kind_of(SimpleHttpMonitor::CheckResult))
      subject.check
    end
    describe 'saves failed check result' do
      let(:store) { SimpleHttpMonitor::Store.new(work_dir) }
      it 'to file' do
        subject.check

        result = store.load(SimpleHttpMonitor::CheckResult)
        expect(result.uri).to eq(url)
        expect(result.status).to eq(200)
      end
      it 'sends notification in case of hitting one of tries' do
        FakeWeb.register_uri(:get, url, body: '', status: 404)

        expect(SimpleHttpMonitor::Mailer).to receive(:send_failure_notification)
        subject.check
        subject.check
      end
    end
  end
end
