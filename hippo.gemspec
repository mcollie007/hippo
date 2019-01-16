# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hippo/version"

Gem::Specification.new do |s|
  s.name        = "hippo"
  s.version     = Hippo::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Jackson", 'Jon Jackson']
  s.email       = ["robertj@promedicalinc.com"]
  s.homepage    = "http://github.com/promedical/hippo"
  s.summary     = %q{HIPAA Transaction Set Generator/Parser}
  s.description = %q{HIPAA Transaction Set Generator/Parser}
  s.license     = 'BSD 2-Clause'

  s.rubyforge_project = "hippo"

  s.add_development_dependency('minitest')
  s.add_development_dependency('rake', '~>10.0.2')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
