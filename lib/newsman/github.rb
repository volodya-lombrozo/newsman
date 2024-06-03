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

class Github
  def initialize(token)
    @client = Octokit::Client.new(github_token: token)
  end

  def pull_requests(username, repositories)
    one_week_ago = date_one_week_ago(Date.today)
    query = "is:pr author:#{username} created:>=#{one_week_ago} #{repositories}"
    puts "Searching pull requests for #{username}."
    puts 'Newsman uses the following request to GitHub to gather the'\
      " required information about user activity: '#{query}'"
    prs = []
    pull_requests = @client.search_issues(query)
    pull_requests.items.each do |pr|
      title = pr.title.to_s
      description = pr.body.to_s
      repository = pr.repository_url.split('/').last
      puts "Found PR in #{repository}: #{title}"
      pr = PullRequest.new(repository, title, description, url: pr.html_url)
      prs << pr
    end
    prs
  end

  def issues(username, repositories)
    one_month_ago = Date.today.prev_month.strftime('%Y-%m-%d')
    issues_query = "is:issue is:open author:#{username}"\
      " author:0pdd created:>=#{one_month_ago} #{repositories}"
    puts "Searching issues using the following query: '#{issues_query}'"
    issues = []
    @client.search_issues(issues_query).items.each do |issue|
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
    issues
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
