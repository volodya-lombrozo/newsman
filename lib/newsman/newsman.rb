#!/usr/bin/env ruby

require 'octokit'
require 'openai'
require 'dotenv'
require 'optparse'
require_relative 'pull_request.rb'

def generate
  # Load all required environment variables
#  Dotenv.load
#  Dotenv.require_keys("GITHUB_TOKEN", "OPENAI_TOKEN")
  # Load all options required
  # Pay attention that some of them have default values.
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: newsman [options]"
    opts.on("-n", "--require NAME", "Reporter name. Human readable name that will be used in a report") do |n|
      options[:name] = n 
    end
    opts.on("-p", "--position", "Reporter position in a company. Default value is a 'Software Developer'.") do |p|
      options[:position] = p
    end
  end.parse!
  options[:name] ||= "Vladimir Zakharov"
  options[:position] ||= "Software Developer"

  all_params = options.map { |key, value| "#{key}: #{value}" }.join(", ")
  puts "Parsed parameters: #{all_params}"

  exit
  # Init all required parameters
  # Reporter Info
  reporter = options[:name]
  reporter_position = options[:position]
  # GitHub 
  username = 'volodya-lombrozo'
  # Your GitHub personal access token
  # Make sure it has the 'repo' 
  github_token = ENV['GITHUB_TOKEN']
  # Your OpenAI personal access token
  openai_token = ENV['OPENAI_TOKEN']
  # Create a GitHub client instance with your access token
  client = Octokit::Client.new(github_token: github_token)
  # Calculate the date one week ago
  one_week_ago = date_one_week_ago(Date.today)
  # Display pull request
  query = "is:pr author:#{username} created:>=#{one_week_ago} repo:objectionary/jeo-maven-plugin repo:objectionary/opeo-maven-plugin"
  puts "Searching pull requests for #{username}."
  puts "Newsman uses the following request to GitHub to gather the required information about user activity: '#{query}'"
  prs = []
  pull_requests = client.search_issues(query)
  pull_requests.items.each do |pr|
    title = "#{pr.title}"
    description = "#{pr.body}"
    repository = pr.repository_url.split('/').last
    puts "Found PR in #{repository}: #{title}"
    # Create a new PullRequest object and add it to the list
    pr = PullRequest.new(repository, title, description)
    prs << pr
  end
  puts "\nNow lets test some aggregation using OpenAI\n\n"
  openai_client = OpenAI::Client.new(github_token: openai_token)
  example = "Last week achievements.
  jeo-meven-plugin:
  - Added 100 new files to the Dataset [#168]
  - Fixed the deployment of XYZ [#169]
  - Refined the requirements [#177]
  opeo-maven-plugin
  - Removed XYZ class [#57]
  - Refactored http module [#69]

  Next week plans:
  jeo-maven-plugin:
  - <leave empty>
  opeo-maven-plugin:
  - <leave empty>

  Risks:
jeo-maven-plugin:
- <leave-empty>
opeo-maven-plugin:
- <leave-empty>

Best regards,
#{reporter}  
#{reporter_position}  
#{report_date}
"

response = openai_client.chat(
    parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "system", content: "You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor."},
          { role: "user", content: "Please compile a summary of the work completed in the following Pull Requests (PRs). Each PR should be summarized in a single sentence, focusing more on the PR title and less on implementation details. Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the PR. The grouping is important an should be precise. Ensure that each sentence includes the corresponding issue number as an integer value. If a PR doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided. Example of a report: #{example}. List of Pull Requests: [#{prs}]"}
        ],
        temperature: 0.3,
    })
puts response.dig("choices", 0, "message", "content")
end


def date_one_week_ago(today)
  # Convert today to a Date object if it's not already
  today = Date.parse(today) unless today.is_a?(Date)
  # Subtract 7 days to get the date one week ago
  one_week_ago = today - 7
  # Format the date as "YYYY-MM-DD"
  formatted_date = one_week_ago.strftime("%Y-%m-%d")
  # Return the formatted date
  return formatted_date
end


# Execute the function only if this script is run directly like `./newsman.rb`
if __FILE__ == $0
  generate()
end

