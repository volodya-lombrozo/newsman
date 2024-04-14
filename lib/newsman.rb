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
    pr = PullRequest.new(repository, title, description)
    prs << pr
  end
  prs = prs.map(&:to_s).join("\n\n\n")

  puts "Searching issues using the following query: '#{issues_query}'"
  issues = []
  client.search_issues(issues_query).items.each do |issue|
    title = issue.title.to_s
    body = issue.body.to_s
    repository = issue.repository_url.split('/').last
    number = issue.number.to_s
    puts "Found issue in #{repository}:[##{number}] #{title}"
    issues << if issue.user.login == '0pdd'
                PddIssue.new(title, body, repository, number)
              else
                Issue.new(title, body, repository, number)
              end
  end
  issues = issues.map(&:to_s).join("\n\n\n")
  # puts "Found issues:\n #{issues}"

  puts "\nNow lets test some aggregation using OpenAI\n\n"
  openai_client = OpenAI::Client.new(access_token: openai_token)

  example = "some-repository-name-x:
  - Added 100 new files to the Dataset [#168]
  - Fixed the deployment of XYZ [#169]
  - Refined the requirements [#177]
  some-repository-name-y:
  - Removed XYZ class [#57]
  - Refactored http module [#69]"

  example_plans = "some-repository-name-x:
  - To publish ABC package draft [#27]
  - To review first draft of the report [#56]
  some-repository-name-y:
  - To implement optimization for the class X [#125]"

  example_risks = "some-repository-name-x:
  - The server is weak, we may fail the delivery
  of the dataset, report milestone will be missed [#487].
some-repository-name-y:
  - The code in repository is suboptimal, we might have some problems for the future maintainability [#44].
  "

  response = openai_client.chat(
    parameters: {
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system',
          content: 'You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.' },
        { role: 'user',
          content: "Please compile a summary of the work completed in the following Pull Requests (PRs). Each PR should be summarized in a single sentence, focusing more on the PR title and less on implementation details. Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the PR. Pay attention, that you don't lose any PR. The grouping is important an should be precise. Ensure that each sentence includes the corresponding issue number as an integer value. If a PR doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided. Example of a report: #{example}. List of Pull Requests: [#{prs}]" }
      ],
      temperature: 0.3
    }
  )
  answer = response.dig('choices', 0, 'message', 'content')
  issues_response = openai_client.chat(
    parameters: {
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system',
          content: 'You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.' },
        { role: 'user',
          content: "Please compile a summary of the plans for the next week using the following GitHub Issues descriptions. Each issue should be summarized in a single sentence, focusing more on the issue title and less on implementation details. Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the issue. Pat attention, that you din't loose any issue. The grouping is important an should be precise. Ensure that each sentence includes the corresponding issue number as an integer value. If an issue doesn't mention an issue number, just print [#chore]. Combine all the information from each Issue into a concise and fluent sentences, as if you were a developer reporting on your work. Please strictly adhere to the example template provided: #{example_plans}. List of GitHub issues to aggregate: [#{issues}]. Use the same formatting as here \n```#{answer}```\n" }
      ],
      temperature: 0.3
    }
  )
  issues_full_answer = issues_response.dig('choices', 0, 'message', 'content')

  risks_full_answer = openai_client.chat(
    parameters: {
      model: 'gpt-3.5-turbo',
      messages: [
        { role: 'system',
          content: 'You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.' },
        { role: 'user',
          content: "Please compile a summary of the risks identified in some repositories. If you can't find anything, just leave answer empty. Add some entries to a report only if you are sure it's a risk. Developers usually mention some risks in pull request descriptions. They either mention 'risk' or 'issue'. I will give you a list of pull requests. Each risk should be summarized in a single sentence. Ensure that each sentence includes the corresponding issue number or PR number as an integer value. If a PR or an issue doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided. Example of a report: #{example_risks}. List of Pull Requests: ```#{prs}```.]" }
      ],
      temperature: 0.3
    }
  ).dig('choices', 0, 'message', 'content')

  output_mode = options[:output]
  puts "Output mode is '#{output_mode}'"
  full_answer = Report.new(reporter, reporter_position, options[:title]).build(answer, issues_full_answer,
                                                                               risks_full_answer, Date.today)
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
