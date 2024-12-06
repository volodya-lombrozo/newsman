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

require 'net/http'
require 'json'

IMPORTANT_ISSUE = 'soon'

# This class represents a GitHub Issue abstraction created by a user.
class Issue
  attr_accessor :title, :body, :repo, :number

  def initialize(title, body, repo, number, **additional)
    defaults = { url: 'undefined', labels: [] }
    @title = title
    @body = body
    @repo = repo
    @number = number
    @additional = defaults.merge(additional)
  end

  def to_s
    <<~MARKDOWN
      title: ```#{@title}```,
      description: ```#{@body}```,
      repo: ```#{@repo}```,
      issue number: \##{@number},
      additional: #{@additional}
    MARKDOWN
  end

  def detailed_title
    "title: #{@title}, repo: #{@repo}, number: \##{@number}, url: #{url}, labels: #{labels}"
  end

  def url
    @additional[:url]
  end

  def labels
    @additional[:labels]
  end

  def to_json(*_args)
    {
      number: @number,
      title: @title,
      description: @body,
      repository: @repo,
      url: url.to_s
    }.to_json
  end

  def important?
    labels.include? IMPORTANT_ISSUE
  end
end

# This class represents a GitHub issue abstraction created by a 0pdd robot.
class PddIssue
  attr_accessor :repo

  def initialize(title, body, repo, number, **additional)
    defaults = { url: 'undefined', labels: [] }
    @title = title
    @body = body
    @repo = repo
    @number = number
    @additional = defaults.merge(additional)
  end

  def extract_real_body
    address = issue_link
    line_numbers = address.scan(/#L(\d+)-L(\d+)/).flatten.map(&:to_i)
    uri = URI(address)
    Net::HTTP.get(uri).lines[line_numbers[0] - 1..line_numbers[1]]
  end

  def issue_link
    @body[%r{https://github\.com/[\w\-/]+/blob/[\w\d]+/[\w/.-]+#\w+-\w+}, 0]
      .gsub('https://github.com', 'https://raw.githubusercontent.com')
      .gsub('blob/', '')
  end

  def to_s
    <<~MARKDOWN
      title: ```#{@title}```,
      description: ```#{extract_real_body}```,
      repo: ```#{@repo}```,
      issue number: \##{@number},
      additional: #{@additional}
    MARKDOWN
  end

  def detailed_title
    "title: #{@title}, repo: #{@repo}, issue number: \##{@number}, url: #{url}, labels: #{labels}"
  end

  def to_json(*_args)
    {
      number: @number,
      title: @title,
      description: @body,
      repository: @repo,
      url: url.to_s
    }.to_json
  end

  def important?
    labels.include? IMPORTANT_ISSUE
  end

  def url
    @additional[:url]
  end

  def labels
    @additional[:labels]
  end
end
