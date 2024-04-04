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
require_relative '../lib/newsman/html_output'

class TestHtmlout < Minitest::Test

  EXPECTED = "<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"UTF-8\">
  <title>volodya-lombrozo 04.04.2024</title>
</head>
<body>
  <h1>volodya-lombrozo 04.04.2024</h1>
  <p>Issue description</p>
</body>
</html>
"

  def test_writes_to_a_html_file
    Dir.mktmpdir do |temp_dir|
      output = Htmlout.new(temp_dir)
      today = Date.today.strftime('%d.%m.%Y')
      expected = "#{today}.volodya-lombrozo.html"
      output.print("Issue description", 'volodya-lombrozo')
      assert(File.exist?(File.join(temp_dir, expected)))
      assert_equal(EXPECTED, File.read(File.join(temp_dir, expected)))
    end
  end
end
