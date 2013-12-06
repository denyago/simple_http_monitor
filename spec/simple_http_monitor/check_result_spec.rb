require 'spec_helper'

describe SimpleHttpMonitor::CheckResult do
  subject { described_class.new(params) }
  let(:params) do
    {
      uri:        uri,
      status:     status,
      failed_try: failed_try,
      timeout:    timeout
    }
  end
  let(:uri)        { 'http://example.com' }
  let(:status)     { '300' }
  let(:failed_try) { nil }
  let(:timeout)    { nil }

  describe 'attributes' do
    let(:failed_try) { '77' }
    let(:timeout)    { 100 }

    it { expect(subject.status).to     eq(300)}
    it { expect(subject.uri).to        eq(uri)}
    it { expect(subject.failed_try).to eq(77) }
    it { expect(subject.timeout).to    eq(100)}
  end

  describe 'setters' do
    it 'set .failed_try' do
      subject.failed_try = 500
      expect(subject.failed_try).to eq(500)
    end
  end

  describe '.inspect' do

  end

  describe '.result' do
    context 'when everything is fine' do
      it { expect(subject.result).to eq(:ok) }
    end
    context 'when status code not succesfull' do
      let(:status) { 502 }
      it { expect(subject.result).to eq(:http_code_error) }
    end
    context 'when timeout of connction' do
      let(:timeout) { 100 }
      it { expect(subject.result).to eq(:connection_timeout_error) }
    end
  end

  describe '.failed?' do
    context 'with faily response status code' do
      let(:status) { 500 }

      it { expect(subject).to be_failed }
    end

    context 'with nil failed_try' do
      context 'with nil timeout' do
        it { expect(subject).to_not be_failed }
      end
      context 'with present timeout' do
        let(:timeout) { 100 }
        it { expect(subject).to be_failed }
      end
    end
  end
end
