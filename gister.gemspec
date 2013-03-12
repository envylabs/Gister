# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gister/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric Allam"]
  gem.email         = ["rubymaverick@gmail.com"]
  gem.description   = %q{Provides a Middleware to cache embedded gist content}
  gem.summary       = %q{Provides a Middleware to cache embedded gist content}
  gem.homepage      = "https://github.com/envylabs/Gister"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "gister"
  gem.require_paths = ["lib"]
  gem.version       = Gister::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "vcr", "~> 2.0.0"
  gem.add_development_dependency "webmock"

  gem.add_runtime_dependency "faraday", "~> 0.6.1"
end
