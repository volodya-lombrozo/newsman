# frozen_string_literal: true

require 'rake/testtask'
desc 'Run all unit tests'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc 'Build the gem'
task :build do
  sh 'gem build newsman.gemspec'
end

desc 'Install the gem locally'
task install: [:build] do
  gem_file = find_latest_gem
  sh "gem install #{gem_file}" if gem_file
end

desc 'Push the latest gem version to RubyGems.org'
task publish: [:install] do
  gem_file = find_latest_gem
  sh "gem push #{gem_file}" if gem_file
  Rake::Task['clean'].invoke
end

desc 'Remove latest gem'
task :clean do
  gem_file = find_latest_gem
  File.delete(gem_file)
end

require 'rubocop/rake_task'
desc 'Run RuboCop on all directories'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

def find_latest_gem
  Dir['*.gem'].max_by { |file| File.mtime(file) }
end
