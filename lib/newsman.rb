#!/usr/bin/env ruby
# frozen_string_literal: true

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
            "Specify which repositories to include in a report. You can specify several repositories using a comma separator, for example: '-r objectionary/jeo-maven-plugin,objectionary/opeo-maven-plugin'") do |r|
      options[:repositories] = r
    end
    opts.on('-p', '--position POSITION',
            "Reporter position in a company. Default value is a 'Software Developer'.") do |p|
      options[:position] = p
    end
    opts.on('-o', '--output OUTPUT',
            "Output type. Newsman prints a report to a stdout by default. You can choose another options like '-o html', '-o txt' or even '-o html'") do |o|
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
                         'GitHub repository is required. Please specify one or several repositories using -r or --repositories.')
  options[:position] ||= 'Software Developer'
  options[:output] ||= 'stdout'
  options[:title] ||= ''
  all_params = options.map { |key, value| "#{key}: #{value}" }.join(', ')
  puts "Parsed parameters: #{all_params}"

  # Load all required environment variables
  Dotenv.load
  Dotenv.require_keys('GITHUB_TOKEN', 'OPENAI_TOKEN')

  # Init all required parameters
  # Reporter Info
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
  client = Octokit::Client.new(github_token: github_token)
  # Calculate the date one week ago
  one_week_ago = date_one_week_ago(Date.today)
  one_month_ago = Date.today.prev_month.strftime('%Y-%m-%d')
  # Display pull request
  query = "is:pr author:#{github_username} created:>=#{one_week_ago} #{github_repositories}"
  issues_query = "is:issue is:open author:#{github_username} author:0pdd created:>=#{one_month_ago} #{github_repositories}"
  puts "Searching pull requests for #{github_username}."
  puts "Newsman uses the following request to GitHub to gather the required information about user activity: '#{query}'"
  prs = []
  pull_requests = client.search_issues(query)
  pull_requests.items.each do |pr|
    title = pr.title.to_s
    description = pr.body.to_s
    repository = pr.repository_url.split('/').last
    puts "Found PR in #{repository}: #{title}"
    # Create a new PullRequest object and add it to the list
    pr = PullRequest.new(repository, title, description, url: pr.html_url)
    prs << pr
  end
  raw_prs = prs
  prs = prs.map(&:to_s).join("\n\n\n")
  grouped_prs = raw_prs.group_by { |pr| pr.repository }

  puts "Searching issues using the following query: '#{issues_query}'"
  issues = []
  client.search_issues(issues_query).items.each do |issue|
    title = issue.title.to_s
    body = issue.body.to_s
    repository = issue.repository_url.split('/').last
    number = issue.number.to_s
    puts "Found issue in #{repository}:[##{number}] #{title}"
    issues << if issue.user.login == '0pdd'
                PddIssue.new(title, body, repository, number, url: issue.html_url)
              else
                Issue.new(title, body, repository, number, url: issue.html_url)
              end
  end
  raw_issues = issues
  issues = issues.map(&:to_s).join("\n\n\n")
  grouped_issues = raw_issues.group_by { |iss| iss.repo }

  puts "\nNow lets test some aggregation using OpenAI\n\n"
  openai_client = OpenAI::Client.new(access_token: openai_token)
  
  assistant = Assistant.new(openai_token)
  
  old_way = false
  if old_way
    answer = assistant.old_prev_results(prs)
    issues_full_answer = assistant.old_next_plans(issues) 
    risks_full_answer = assistant.old_risks(prs)
 else
    puts "Assistant builds a report using a new approach, using groupping"
    # Build previous results
    answer = "" 
    grouped_prs.each do |repository, rprs|
      puts "Building a results report for the repository: #{repository}"
      answer = answer + assistant.prev_results(rprs.map(&:to_s).join("\n\n\n"))
    end
    # Build next plans 
    issues_full_answer = "" 
    grouped_issues.each do |repository, rissues|
      puts "Building a future plans report for the repository: #{repository}"
      issues_full_answer = issues_full_answer + assistant.next_plans(rissues.map(&:to_s).join("\n\n\n"))
    end
    # Find risks
    risks_full_answer = assistant.risks(prs)
  end

  full_answer = Report.new(
    reporter, 
    reporter_position, 
    options[:title],
    additional: ReportItems.new(raw_prs, raw_issues)
  ).build(
    answer, 
    issues_full_answer,
    risks_full_answer, 
    Date.today
  )

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

def date_one_week_ago(today)
  # Convert today to a Date object if it's not already
  today = Date.parse(today) unless today.is_a?(Date)
  # Subtract 7 days to get the date one week ago
  one_week_ago = today - 7
  # Format the date as "YYYY-MM-DD"
  one_week_ago.strftime('%Y-%m-%d')
  # Return the formatted date
end

def week_of_a_year(project, today)
  number = today.strftime('%U').to_i + 1
  "WEEK #{number} #{project}"
end

# Execute the function only if this script is run directly like `./newsman.rb`
generate if __FILE__ == $PROGRAM_NAME
