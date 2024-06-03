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
require_relative '../lib/newsman/report'
require_relative '../lib/newsman/issues'
require_relative '../lib/newsman/pull_request'

class TestReport < Minitest::Test
  REPORT_EXAMPLE = <<~EXPECTED
    From: User
    Subject: WEEK 11 Project

    Hi all,

    Last week achievements:
    repository-a:
     - Did a lot of for (a) repository

    Next week plans:
    repository-b:
     - I will do a lot for repository (b)

    Risks:
    - <todo>

    Best regards,
    User
    Developer
    2024-03-14
  EXPECTED

  def test_report
    expected = REPORT_EXAMPLE
    report = Report.new('User', 'Developer', 'Project')
    out = report.build("repository-a:\n - Did a lot of for (a) repository",
                       "repository-b:\n - I will do a lot for repository (b)",
                       '- <todo>',
                       Date.new(2024, 3, 14))
    assert_equal expected, out
  end

  def test_report_items
    expected = <<~EXPECTED
      Closed Pull Requests:
       - title: title, repo: repo, url: http://some.url.com

      Open Issues:
       - title: title, repo: repo, number: #123, url: http://google.com, labels: []
    EXPECTED
    issues = [Issue.new('title', 'body', 'repo', '123', url: 'http://google.com')]
    prs = [PullRequest.new('repo', 'title', 'body', url: 'http://some.url.com')]
    actual = ReportItems.new(prs, issues).to_s
    assert_equal expected, actual
  end
end
