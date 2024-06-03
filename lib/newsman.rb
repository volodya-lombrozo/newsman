#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Copyright (c) 2024 Volodya Lombrozo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'octokit'
require 'openai'
require 'dotenv'
require 'optparse'
require_relative 'newsman/pull_request'
require_relative 'newsman/issues'
require_relative 'newsman/stdout_output'
require_relative 'newsman/txt_output'
require_relative 'newsman/html_output'
require_relative 'newsman/report'
require_relative 'newsman/assistant'
require_relative 'newsman/github'

# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
def generate
  # Load all options required
  # Pay attention that some of them have default values.
  options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: newsman [options]'
    opts.on('-n', '--name NAME', 'Reporter name. Human readable name that will be used in a report') do |n|
      options[:name] = n
    end
    opts.on('-u', '--username USERNAME', "GitHub username. For example, 'volodya-lombrozo'") do |u|
      options[:username] = u
    end
    opts.on('-r', '--repository REPOSITORIES',
            'Specify which repositories to include in a report.'\
            'You can specify several repositories using a comma separator,'\
            "for example: '-r objectionary/jeo-maven-plugin,objectionary/opeo-maven-plugin'") do |r|
      options[:repositories] = r
    end
    opts.on('-p', '--position POSITION',
            "Reporter position in a company. Default value is a 'Software Developer'.") do |p|
      options[:position] = p
    end
    opts.on('-o', '--output OUTPUT',
            'Output type. Newsman prints a report to a stdout by default.'\
            "You can choose another options like '-o html', '-o txt' or even '-o html'") do |o|
      options[:output] = o
    end
    opts.on('-t', '--title TITLE', 'Project Title. Empty by default') do |t|
      options[:title] = t
    end
  end.parse!
  # Custom method to raise exception with a human-readable message
  def options.require_option(key, message)
    raise OptionParser::MissingArgument, message if self[key].nil?
  end
  # Check for required options
  options.require_option(:name, 'Reporter name is required. Please specify using -n or --name.')
  options.require_option(:username, 'GitHub username is required. Please specify using -u or --username.')
  options.require_option(:repositories,
                         'GitHub repository is required.'\
                         ' Please specify one or several repositories using -r or --repositories.')
  options[:position] ||= 'Software Developer'
  options[:output] ||= 'stdout'
  options[:title] ||= ''
  all_params = options.map { |key, value| "#{key}: #{value}" }.join(', ')
  puts "Parsed parameters: #{all_params}"
  load_environment_variables
  # Init all required parameters Reporter Info
  reporter = options[:name]
  reporter_position = options[:position]
  # GitHub
  github_username = options[:username]
  github_repositories = options[:repositories].split(',').map { |repo| "repo:#{repo}" }.join(' ')
  # Your GitHub personal access token
  # Make sure it has the 'repo'
  github_token = ENV['GITHUB_TOKEN']
  # Your OpenAI personal access token
  openai_token = ENV['OPENAI_TOKEN']
  # Create a GitHub client instance with your access token
  github = Github.new(github_token)
  prs = github.pull_requests(github_username, github_repositories)
  issues = github.issues(github_username, github_repositories)
  puts "\nNow lets test some aggregation using OpenAI\n\n"
  assistant = Assistant.new(openai_token)
  # Build previous results
  answer = ''
  prs.group_by(&:repository).each do |repository, rprs|
    puts "Building a results report for the repository: #{repository}"
    answer = "#{answer}\n#{assistant.prev_results(join(rprs))}"
  end
  # Build next plans
  issues_full_answer = ''
  issues.group_by(&:repo).each do |repository, rissues|
    puts "Building a future plans report for the repository: #{repository}"
    issues_full_answer = "#{issues_full_answer}\n#{assistant.next_plans(join(rissues))}"
  end
  # Build report
  report = Report.new(
    reporter,
    reporter_position,
    options[:title],
    additional: ReportItems.new(prs, issues)
  )
  full_answer = assistant.format(report.build(
    answer,
    issues_full_answer,
    assistant.risks(join(prs)),
    Date.today
  ))
  full_answer = report.append_additional(full_answer)
  output_mode = options[:output]
  puts "Output mode is '#{output_mode}'"
  if output_mode.eql? 'txt'
    puts 'Print result to txy file'
    output = Txtout.new('.')
    output.print(full_answer, github_username)
  elsif output_mode.eql? 'html'
    puts 'Print result to html file'
    output = Htmlout.new('.')
    output.print(full_answer, github_username)
  else
    puts 'Print result to stdout'
    output = Stdout.new
    output.print(full_answer)
  end
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

def load_environment_variables
  Dotenv.load
  Dotenv.require_keys('GITHUB_TOKEN', 'OPENAI_TOKEN')
end

def join(items)
  "[#{items.map(&:to_json).join(',')}]"
end

# Execute the function only if this script is run directly like `./newsman.rb`
generate if __FILE__ == $PROGRAM_NAME
