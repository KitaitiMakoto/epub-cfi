# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'epub/cfi/version'

Gem::Specification.new do |gem|
  gem.name          = "epub-cfi"
  gem.version       = EPUB::CFI::VERSION
  gem.summary       = %q{EPUB CFI parser and builder}
  gem.description   = %q{Parser and builder implementation for EPUB CFI defined at http://www.idpf.org/epub/linking/cfi/}
  gem.license       = "LGPL"
  gem.authors       = ["KITAITI Makoto"]
  gem.email         = "KitaitiMakoto@gmail.com"
  gem.homepage      = "http://www.idpf.org/epub/linking/cfi/"

  gem.files         = `git ls-files`.split($/)

  `git submodule --quiet foreach --recursive pwd`.split($/).each do |submodule|
    submodule.sub!("#{Dir.pwd}/",'')

    Dir.chdir(submodule) do
      `git ls-files`.split($/).map do |subpath|
        gem.files << File.join(submodule,subpath)
      end
    end
  end
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rubygems-tasks'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency "test-unit"
  gem.add_development_dependency "test-unit-notify"
  gem.add_development_dependency "pretty_backtrace"
end
