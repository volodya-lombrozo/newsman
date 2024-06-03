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

class TestIssue < Minitest::Test
  def test_converts_issue_to_json
    issue = Issue.new(
      'AnnotationsApplication.java:32-35: Check default values...',
      'TEST_BODY',
      'jeo-maven-plugin',
      531
    )
    expected = <<~JSON.chomp
      {"number":531,"title":"AnnotationsApplication.java:32-35: Check default values...","description":"TEST_BODY","repository":"jeo-maven-plugin","url":"undefined"}
    JSON
    assert_equal expected, issue.to_json
  end

  def test_important_issue
    issue = Issue.new(
      'Important Issue Title',
      'Important Issue Body',
      'jeo-maven-plugin',
      531,
      labels: ['soon']
    )
    assert issue.important?
  end

  def test_unimportant_issue
    issue = Issue.new(
      'Unimportant Issue Title',
      'Unimportant Issue Body',
      'jeo-maven-plugin',
      531,
      labels: ['not-soon']
    )
    assert !issue.important?
  end
end
