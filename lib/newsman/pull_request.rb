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
require 'json'

# This class represents GitHub Pull Request abstraction.
# In the future, it might be any Pull or Merge request.
class PullRequest
  attr_accessor :repository, :title, :description
  attr_reader :url

  def initialize(repository, title, description, url: 'undefined')
    @repository = repository
    @title = title
    @description = description
    @url = url
  end

  def to_json(*_args)
    {
      title: @title,
      description: @description,
      repository: @repository,
      url: @url
    }.to_json
  end

  def to_s
    "title: ```#{@title}```,\ndescription: ```#{@description}```,\nrepo: ```#{@repository}```\n"
  end

  def detailed_title
    "title: #{@title}, repo: #{@repository}, url: #{@url}"
  end
end
