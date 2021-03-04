# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','steg','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'steg'
  s.version = Steg::VERSION
  s.author = 'Your Name Here'
  s.email = 'your@email.address.com'
  s.homepage = 'http://your.website.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A description of your project'
  s.files = `git ls-files`.split("
")
  s.require_paths << 'lib'
  s.extra_rdoc_files = ['README.rdoc','steg.rdoc']
  s.rdoc_options << '--title' << 'steg' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'steg'
  s.add_development_dependency('rake','~> 0.9.2')
  s.add_development_dependency('rdoc', '~> 4.3')
  s.add_development_dependency('minitest', '~> 5.14')
  s.add_runtime_dependency('gli','~> 2.20.0')
end
