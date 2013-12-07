require 'spec_helper'

describe SimpleHttpMonitor::Checker do
  subject { described_class.new(uri, timeout) }
  let(:timeout) { 2 }
  let(:uri)     { 'http://example.com' }

  describe 'checks response time' do
    it 'by specifying timeout' do
      Net::HTTP.any_instance.should_receive(:request).and_raise(Timeout::Error)
    end

    it 'by specifying timeout' do
      Net::HTTP.should_receive(:start).and_raise(Errno::ECONNREFUSED)
    end

    after do
      result = subject.check
      expect(result[:timeout]).to eq(2)
    end
  end
end
