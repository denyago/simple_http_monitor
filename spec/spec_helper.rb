require 'bundler/setup'

Bundler.require :default
Bundler.require :development

STORE_DIR = '/tmp/test_simple_http_monitor'

RSpec.configure do |config|
  config.before(:each) do
    FileUtils.rm_rf(STORE_DIR)
    FileUtils.mkdir(STORE_DIR)
  end
end
