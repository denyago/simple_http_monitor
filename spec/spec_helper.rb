require 'bundler/setup'

Bundler.require :default
Bundler.require :development

require 'json'
require 'coveralls'
Coveralls.wear!

STORE_DIR = '/tmp/test_simple_http_monitor'

RSpec.configure do |config|
  config.before(:suite) do
    Mail.defaults do
      delivery_method :test
    end
  end

  config.before(:each) do
    FileUtils.rm_rf(STORE_DIR)
    FileUtils.mkdir(STORE_DIR)

    Mail::TestMailer.deliveries.clear
  end
end
