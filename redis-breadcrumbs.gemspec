# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "redis-breadcrumbs/version"

Gem::Specification.new do |s|
  s.name        = "redis-breadcrumbs"
  s.version     = RedisBreadcrumbs::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Eoin Coffey']
  s.email       = ['ecoffey@gmail.com']
  s.homepage    = "https://github.com/ecoffey/redis-breadcrumbs"
  s.summary     = %q{A friendly DSL for tracking and cleaning up redis keys.}

  s.description = %q{Inherit from Redis::Breadcrumb to get going!}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake", ">= 0.9.2"
  s.add_development_dependency "redis", "~> 3.0.0"
  s.add_development_dependency "minitest", "~> 4.3.2"
end