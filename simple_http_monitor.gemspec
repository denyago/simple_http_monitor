# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'simple_http_monitor/version'

Gem::Specification.new do |spec|
  spec.name          = "simple_http_monitor"
  spec.version       = SimpleHttpMonitor::VERSION
  spec.authors       = ["Denis Yagofarov"]
  spec.email         = ["denyago@gmail.com"]
  spec.description   = %q{Simple script for moniyoring of HTTP servers}
  spec.summary       = %q{Monior HTTP servers, by scheduling of the script and getting notifications}
  spec.homepage      = "https://github.com/denyago/simple_http_monitor"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'mail'
  spec.add_dependency 'slop'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakeweb"
  spec.add_development_dependency "pry-debugger"
end
