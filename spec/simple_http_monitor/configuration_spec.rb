require 'spec_helper'

describe SimpleHttpMonitor::Configuration do
  subject { described_class.new(email, url, tries) }

  describe 'attributes' do
    let(:email)    { 'ors@example.com' }
    let(:url)      { 'http://example.com' }
    let(:tries)    { [2, 10, 50, 100, 500] }

    it { expect(subject.email).to eq(email) }
    it { expect(subject.url).to eq(url) }
    it { expect(subject.tries).to eq(tries) }
  end
end
