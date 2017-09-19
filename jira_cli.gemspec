# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jira_cli/version'

Gem::Specification.new do |spec|
  spec.name          = 'jira_cli'
  spec.version       = JiraCli::VERSION
  spec.authors       = ['Sean Huber']
  spec.email         = ['seanhuber@seanhuber.com']

  spec.summary       = 'A ruby wrapper for JIRA Command Line Interface [Bob Swift Atlassian Add-on]'
  spec.homepage      = 'https://github.com/seanhuber/jira_cli'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/}) || ['build_examples.rb', 'debug.rb', 'document_examples.rb', 'examples.yml'].include?(f)
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 5.1.2'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'awesome_print'
end
