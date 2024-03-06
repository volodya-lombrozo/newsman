#!/usr/bin/env ruby

require 'octokit'
require "openai"
require 'dotenv'
require_relative 'pull_request.rb'

def generate

  Dotenv.load
  Dotenv.require_keys("GITHUB_TOKEN", "OPENAI_TOKEN")


# Reporter Info
reporter = "Vladimir Zakharov"
reporter_position = "R&D Software Developer"
report_date = Time.now.strftime("%d/%m/%Y")


# Your GitHub username
username = 'volodya-lombrozo'

# Your GitHub personal access token
# Make sure it has the 'repo' scope
github_token = ENV['GITHUB_TOKEN']

# Your OpenAI personal access token
openai_token = ENV['OPENAI_TOKEN']

# Create a client instance with your access token
client = Octokit::Client.new(github_token: github_token)

# Get the current date
today = Time.now

# Calculate the date one week ago
one_week_ago = today - (7 * 24 * 60 * 60)

# Format dates for GitHub API query
today_str = today.strftime('%Y-%m-%d')
one_week_ago_str = one_week_ago.strftime('%Y-%m-%d')

# Retrieve pull requests for the specified user within the last week
#pull_requests = client.search_issues('is:pr author:volodya-lombrozo created:>=2024-02-19 repo:objectionary/jeo-maven-plugin')
#pull_requests = client.pull_requests('objectionary/jeo-maven-plugin', state: 'closed', direction: 'desc', since: one_week_ago_str, head: 'volodya-lombrozo:*')
#pull_requests = client.pull_requests('objectionary/jeo-maven-plugin', state: 'all', sort: 'created', direction: 'desc')
# Display pull requests
puts "Pull requests for #{username} created in the last week:"

prs = []

pull_requests = client.search_issues('is:pr author:volodya-lombrozo created:>=2024-02-19 repo:objectionary/jeo-maven-plugin repo:objectionary/opeo-maven-plugin')
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

# Execute the function only if this script is run directly
if __FILE__ == $0
  generate()
end

