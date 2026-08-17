#!/usr/bin/env ruby
# frozen_string_literal: true

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

require 'minitest/autorun'
require_relative '../lib/newsman/issues'
require_relative '../lib/newsman/github'

# A fake Octokit client that records every query it receives and answers
# with a canned total_count, so we can assert on the query strings we build
# without touching the network.
class FakeOctokit
  Result = Struct.new(:total_count, :items)

  def initialize(counts)
    @counts = counts
    @queries = []
  end

  attr_reader :queries

  def search_issues(query)
    @queries << query
    Result.new(@counts.fetch(query, 0), [])
  end
end

class TestGithub < Minitest::Test
  def test_issues_reviewed_builds_involves_and_closed_queries
    client = FakeOctokit.new({})
    github = Github.new('token', client: client)
    github.issues_reviewed('volodya-lombrozo', 'repo:objectionary/eo')
    assert(client.queries.any? { |q| q.include?('is:issue') && q.include?('involves:volodya-lombrozo') })
    assert(client.queries.any? do |q|
      q.include?('is:issue') && q.include?('is:closed') && q.include?('involves:volodya-lombrozo')
    end)
  end

  def test_issues_reviewed_returns_reviewed_and_closed_counts
    since = date_one_week_ago(Date.today)
    reviewed_query = "is:issue involves:volodya-lombrozo updated:>=#{since} repo:objectionary/eo"
    closed_query = "is:issue is:closed involves:volodya-lombrozo closed:>=#{since} repo:objectionary/eo"
    client = FakeOctokit.new(reviewed_query => 7, closed_query => 3)
    github = Github.new('token', client: client)
    activity = github.issues_reviewed('volodya-lombrozo', 'repo:objectionary/eo')
    assert_equal 7, activity.reviewed
    assert_equal 3, activity.closed
    assert_equal 'Issues reviewed: 7 (labeled/assigned), 3 closed', activity.to_s
  end

  def test_pull_requests_reviewed_builds_reviewed_by_query
    since = date_one_week_ago(Date.today)
    query = "is:pr reviewed-by:volodya-lombrozo updated:>=#{since} repo:objectionary/eo"
    client = FakeOctokit.new(query => 5)
    github = Github.new('token', client: client)
    assert_equal 5, github.pull_requests_reviewed('volodya-lombrozo', 'repo:objectionary/eo')
  end
end
