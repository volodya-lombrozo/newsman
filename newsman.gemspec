# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'newsman'
  spec.version       = '1.0.0'
  spec.authors       = ['Volodya Lombrozo']
  spec.email         = ['volodya.lombrozo@gmail.com']
  spec.summary       = 'GitHub user weekly news'
  spec.description   = 'A simple gem that gathers GitHub statistics and creates human-readable report'
  spec.homepage      = 'https://github.com/volodya-lombrozo/newsman'
  spec.files         = Dir.glob('{lib}/**/*') + Dir.glob('{bin}/**/*') + Dir.glob('{test,spec}/**/*') + ['README.md',
                                                                                                         'LICENSE.txt']
  spec.executables   = ['newsman'] # Specify the executable name
  spec.require_paths = %w[lib bin]
  spec.license       = 'MIT'

  spec.required_ruby_version = '>=3.0'

  spec.add_development_dependency 'minitest', '~> 5.22'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_runtime_dependency 'json', '~> 2.6'
  spec.add_dependency 'dotenv', '~> 3.1'
  spec.add_dependency 'faraday-retry', '~> 2.2'
  spec.add_dependency 'net-http', '~> 0.4'
  spec.add_dependency 'nokogiri', '~> 1.16'
  spec.add_dependency 'octokit', '~> 8.0'
  spec.add_dependency 'optparse', '~> 0.4.0'
  spec.add_dependency 'redcarpet', '~> 3.6'
  spec.add_dependency 'ruby-openai', '~> 6.3'
end
