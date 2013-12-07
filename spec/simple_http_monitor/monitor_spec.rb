require 'spec_helper'

describe SimpleHttpMonitor::Monitor do
  let(:email)      { 'ors@example.com' }
  let(:url)        { 'http://example.com' }
  let(:tries)      { [2, 10, 50, 100, 500] }
  let(:work_dir)   { STORE_DIR }
  let(:timeout)    { 1 }
  let(:from)       { 'monitor@example.com' }
  let(:smtp_host)  { 'smtp.example.com' }
  let(:smtp_user)  { 'test' }
  let(:smtp_paswd) { 'secret' }

  describe '.initialize' do
    subject     { described_class }

    it 'configures classes' do
      expect(SimpleHttpMonitor::Store).to    receive(:new).with(work_dir)
      expect(SimpleHttpMonitor::Mailer).to   receive(:new).with(from: from, to: email, smtp_host: smtp_host,
                                                              smtp_user: smtp_user, smtp_paswd: smtp_paswd).and_call_original
      expect(SimpleHttpMonitor::Notifier).to receive(:new).with(kind_of(SimpleHttpMonitor::Mailer), tries)
      expect(SimpleHttpMonitor::Checker).to  receive(:new).with(url, timeout)

      subject.new({
        url:        url,
        tries:      tries,
        timeout:    timeout,
        work_dir:   work_dir,
        ops_email:  email,
        from_email: from,
        smtp_host:  smtp_host,
        smtp_user:  smtp_user,
        smtp_paswd: smtp_paswd
      })
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
      subject.stub(:logger).and_return(Logger.new('/dev/null'))
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

      before do
        SimpleHttpMonitor::Mailer.any_instance.stub(:send_failure_notification)
        SimpleHttpMonitor::Mailer.any_instance.stub(:send_back_online_notification)
      end

      let(:store) { SimpleHttpMonitor::Store.new(work_dir) }

      it 'to file' do
        subject.check

        result = store.load(SimpleHttpMonitor::CheckResult)
        expect(result.uri).to eq(url)
        expect(result.status).to eq(200)
      end

      it 'sends notification in case of hitting one of tries' do
        FakeWeb.register_uri(:get, url, body: '', status: 404)

        SimpleHttpMonitor::Mailer.any_instance.should_receive(:send_failure_notification)
        2.times { subject.check }
      end

      describe 'if site becomes available' do
        it 'sends notification, if failure notification already been sent' do
           FakeWeb.register_uri(:get, url,
                                 [{body: '', status: 404},
                                  {body: '', status: 404},
                                  {body: '', status: 200}
                                 ]
                               )
         SimpleHttpMonitor::Mailer.any_instance.should_receive(:send_back_online_notification)
         3.times { subject.check }
       end

       context 'not sends notification if' do
         before do
           FakeWeb.register_uri(:get, url,
                                [{body: '', status: 404},
                                 {body: '', status: 200}
                                ]
                              )
           SimpleHttpMonitor::Mailer.any_instance.should_not_receive(:send_back_online_notification)
         end

         it 'nothing was sent' do
           2.times { subject.check }
         end

         it 'back online notification was sent' do
           3.times { subject.check }
         end
       end
      end
    end
  end
end
