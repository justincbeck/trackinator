# -*- encoding: utf-8 -*-
require File.expand_path('../lib/trackinator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Beck"]
  gem.email         = %w{justinbeck@mac.com}
  gem.description   = <<-EOF
    In order to introduce in to my main development process
    I decided that creating a test plan prior to development
    and then using that as the basis for my YouTrack tickets
    would be a good approach.  Think of it as TDD at a macro
    level.
  EOF
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
