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

class TestPddIssue < Minitest::Test
  TEST_BODY = <<~BODY
    The puzzle `531-462261de` from #531 has to be resolved:

    https://github.com/objectionary/jeo-maven-plugin/blob/5a42b2c9f7e0ff01cbb2c4626e1dc5dc3f8aa7b8/src/it/annotations/src/main/java/org/eolang/jeo/annotations/AnnotationsApplication.java#L32-L35

    The puzzle was created by @volodya-lombrozo on 29-Mar-24.

    Estimate: 90 minutes,  role: DEV.

    If you have any technical questions, don't ask me, submit new tickets instead.
    The task will be "done" when the problem is fixed and the text of the puzzle is _removed_ from the source code.
    Here is more about [PDD](http://www.yegor256.com/2009/03/04/pdd.html) and [about me](http://www.yegor256.com/2017/04/05/pdd-in-action.html).
  BODY

  EXPECTED_DESCRIPTION = [
    "     * @todo #531:90min Check default values for annotation properties.\n",
    "     *  We still encounter some problems with annotation processing.\n",
    "     *  Especially with Autowired annotation from Spring Framework.\n",
    "     *  It's relatively simple annotation, but it's not processed correctly.\n",
    "     */\n"
  ].freeze

  def test_parses_pdd_issue
    issue = PddIssue.new('AnnotationsApplication.java:32-35: Check default values...',
                         TEST_BODY,
                         'jeo-maven-plugin', 531)
    assert_equal(EXPECTED_DESCRIPTION, issue.extract_real_body)
  end

  def test_converts_to_json
    issue = PddIssue.new('AnnotationsApplication.java:32-35: Check default values...',
                         'TEST_BODY',
                         'jeo-maven-plugin', 531)
    expected = <<~JSON.chomp
      {"number":531,"title":"AnnotationsApplication.java:32-35: Check default values...","description":"TEST_BODY","repository":"jeo-maven-plugin","url":"undefined"}
    JSON
    assert_equal(
      expected,
      issue.to_json
    )
  end
end
