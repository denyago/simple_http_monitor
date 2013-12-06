require 'spec_helper'

describe SimpleHttpMonitor::Checker do
  subject { described_class }
  let(:timeout) { 2 }
  let(:uri)     { 'http://example.com' }

  describe 'checks response time' do
    it 'by specifying timeout' do
      Net::HTTP.any_instance.should_receive(:request).and_raise(Timeout::Error)
      result = subject.check(uri, timeout)

      expect(result.timeout).to eq(2)
    end
  end
end
