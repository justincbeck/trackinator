# -*- encoding: utf-8 -*-
require File.expand_path('../lib/trackinator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Beck"]
  gem.email         = %w{justinbeck@mac.com}
  gem.description   = %q{Imports a spreadsheet in to YouTrack}
  gem.summary       = %q{Imports a spreadsheet in to YouTrack}
  gem.homepage      = "https://github.com/justincbeck/trackinator"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "trackinator"
  gem.require_paths = %w{lib}
  gem.version       = Trackinator::VERSION

  gem.add_dependency "gdata_19"
  gem.add_dependency "trollop"
end
