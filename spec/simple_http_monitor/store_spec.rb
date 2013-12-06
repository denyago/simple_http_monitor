require 'spec_helper'

describe SimpleHttpMonitor::Store do
  subject { described_class.new(STORE_DIR) }

  let(:file_path) { File.join(STORE_DIR, 'storage.yml') }

  describe '.save' do
    context 'with path to save' do
      it 'saves object to file' do
        subject.save('foo', 'path.to.save')
      end
    end
    context 'without path to save' do
      it 'saves object to file' do
        subject.save('foo')
      end
    end
    after do
      expect(File.size(file_path)).to_not be_zero
    end
  end

  describe '.load' do
    let(:file_contents) do
      "
---
String: bar
      "
    end

    before do
      File.open(file_path, 'w') { |f| f.write(file_contents) }
    end

    it 'loads object from file' do
      expect(subject.load(String)).to eq('bar')
    end
  end
end
