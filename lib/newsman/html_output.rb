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

require 'erb'
require 'redcarpet'
require 'nokogiri'

# This class represents a report output in HTML format.
class Htmlout
  TEMPLATE = <<~HTML
    <head>
      <title><%= title %></title>
    </head>
    <body>
      <h1><%= title %></h1>
      <%= body %>
    </body>
  HTML

  def initialize(root = '.')
    @root = root
  end

  # rubocop:disable Metrics/AbcSize
  def print(report, reporter)
    title = title(reporter)
    body = to_html(report)
    puts "Create a html file in a directory #{@root}"
    file = File.new(File.join(@root, filename(reporter)), 'w')
    puts "File #{file.path} was successfully created"
    file.puts Nokogiri::HTML(ERB.new(TEMPLATE).result(binding), &:noblanks).to_xhtml(indent: 2)
    puts "Report was successfully printed to a #{file.path}"
    file.close
  end
  # rubocop:enable Metrics/AbcSize

  def title(reporter)
    date = Time.new.strftime('%d.%m.%Y')
    "#{reporter} #{date}"
  end

  def filename(reporter)
    date = Time.new.strftime('%d.%m.%Y')
    "#{date}.#{reporter}.html"
  end

  def to_html(report)
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true, prettify: true),
      autolink: true,
      tables: true
    ).render(report)
  end
end
