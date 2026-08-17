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

# This class represents a useful abstraction over Github API.
class Github
  def initialize(token, client: nil)
    @client = client || Octokit::Client.new(github_token: token)
  end

  def pull_requests(username, repositories)
    query = "is:pr author:#{username} created:>=#{date_one_week_ago(Date.today)} #{repositories}"
    puts "Searching pull requests for #{username}."
    puts 'Newsman uses the following request to GitHub to gather the'\
      " required information about user activity: '#{query}'"
    @client.search_issues(query).items.map do |pull_request|
      parse_pr(pull_request)
    end
  end

  def issues(username, repositories)
    one_year_ago = Date.today.prev_year.strftime('%Y-%m-%d')
    query = "is:issue is:open assignee:#{username}"\
      " created:>=#{one_year_ago} #{repositories} label:#{IMPORTANT_ISSUE}"
    puts "Searching issues using the following query: '#{query}'"
    @client.search_issues(query).items.map do |issue|
      parse_issue(issue)
    end.select(&:important?)
  end

  def issues_reviewed(username, repositories)
    since = date_one_week_ago(Date.today)
    reviewed_query = "is:issue involves:#{username} updated:>=#{since} #{repositories}"
    closed_query = "is:issue is:closed involves:#{username} closed:>=#{since} #{repositories}"
    puts "Searching issues reviewed using the following query: '#{reviewed_query}'"
    reviewed = @client.search_issues(reviewed_query).total_count
    puts "Searching issues closed using the following query: '#{closed_query}'"
    closed = @client.search_issues(closed_query).total_count
    IssueActivity.new(reviewed, closed)
  end

  def pull_requests_reviewed(username, repositories)
    since = date_one_week_ago(Date.today)
    query = "is:pr reviewed-by:#{username} updated:>=#{since} #{repositories}"
    puts "Searching pull requests reviewed using the following query: '#{query}'"
    @client.search_issues(query).total_count
  end

  def parse_pr(pull_request)
    title = pull_request.title.to_s
    repository = pull_request.repository_url.split('/').last
    puts "Found PR in #{repository}: #{title}"
    PullRequest.new(repository, title, pull_request.body.to_s, url: pull_request.html_url)
  end

  def parse_issue(issue)
    title, repository, number = issue_details(issue)
    if issue.user.login == '0pdd'
      PddIssue.new(title, issue.body.to_s, repository, number, url: issue.html_url, labels: issue.labels.map(&:name))
    else
      Issue.new(title, issue.body.to_s, repository, number, url: issue.html_url, labels: issue.labels.map(&:name))
    end
  end

  def issue_details(issue)
    title = issue.title.to_s
    repository = issue.repository_url.split('/').last
    number = issue.number.to_s
    puts "Found issue in #{repository}:[##{number}] #{title}"
    [title, repository, number]
  end
end

def date_one_week_ago(today)
  today = Date.parse(today) unless today.is_a?(Date)
  one_week_ago = today - 7
  one_week_ago.strftime('%Y-%m-%d')
end
