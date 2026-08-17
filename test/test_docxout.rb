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
require 'date'
require 'zip'
require_relative '../lib/newsman/docx_output'

class TestDocxout < Minitest::Test
  def test_writes_to_a_docx_file
    Dir.mktmpdir do |temp_dir|
      output = Docxout.new(temp_dir)
      today = Date.today.strftime('%d.%m.%Y')
      expected = "#{today}.volodya-lombrozo.gpt-3-5-turbo.docx"
      returned = output.print("Issue description\n\nHere is a new paragraph\nList is here:\n - one\n - two\n - three",
                              'volodya-lombrozo',
                              'gpt-3.5-turbo')
      assert_equal(expected, returned)
      assert(File.exist?(File.join(temp_dir, expected)))
    end
  end

  def test_docx_uses_times_new_roman_12pt
    Dir.mktmpdir do |temp_dir|
      output = Docxout.new(temp_dir)
      path = File.join(temp_dir, output.print('Issue description', 'volodya-lombrozo', 'gpt-3.5-turbo'))
      document_xml = Zip::File.open(path) { |zip| zip.read('word/document.xml') }
      assert_includes(document_xml, 'w:ascii="Times New Roman"')
      assert_includes(document_xml, '<w:sz w:val="24"/>')
      assert_includes(document_xml, 'Issue description')
    end
  end

  def test_renders_markdown_headers_as_word_headings
    Dir.mktmpdir do |temp_dir|
      output = Docxout.new(temp_dir)
      report = "# Title\n\n## Subtitle\n\n### Section"
      path = File.join(temp_dir, output.print(report, 'volodya-lombrozo', 'gpt-3.5-turbo'))
      document_xml = Zip::File.open(path) { |zip| zip.read('word/document.xml') }
      %w[Heading1 Heading2 Heading3].each { |style| assert_includes(document_xml, %(<w:pStyle w:val="#{style}"/>)) }
      assert_includes(document_xml, '>Title<')
      refute_includes(document_xml, '# Title')
    end
  end

  def test_renders_markdown_bullet_lists_as_word_lists
    Dir.mktmpdir do |temp_dir|
      output = Docxout.new(temp_dir)
      report = "List is here:\n\n- one\n- two\n* three"
      path = File.join(temp_dir, output.print(report, 'volodya-lombrozo', 'gpt-3.5-turbo'))
      document_xml = Zip::File.open(path) { |zip| zip.read('word/document.xml') }
      assert_includes(document_xml, '<w:numId w:val="1"/>')
      assert_includes(document_xml, '>one<')
      refute_includes(document_xml, '>- one<')
    end
  end

  def test_renders_markdown_numbered_lists_as_word_lists
    Dir.mktmpdir do |temp_dir|
      output = Docxout.new(temp_dir)
      report = "1. first\n2. second"
      path = File.join(temp_dir, output.print(report, 'volodya-lombrozo', 'gpt-3.5-turbo'))
      document_xml = Zip::File.open(path) { |zip| zip.read('word/document.xml') }
      assert_includes(document_xml, '<w:numId w:val="2"/>')
      assert_includes(document_xml, '>first<')
    end
  end

  def test_strips_markdown_bold_markers
    Dir.mktmpdir do |temp_dir|
      output = Docxout.new(temp_dir)
      report = 'Deploys are **blocked** until review, __really__ blocked.'
      path = File.join(temp_dir, output.print(report, 'volodya-lombrozo', 'gpt-3.5-turbo'))
      document_xml = Zip::File.open(path) { |zip| zip.read('word/document.xml') }
      assert_includes(document_xml, 'Deploys are blocked until review, really blocked.')
      refute_includes(document_xml, '**')
      refute_includes(document_xml, '__')
    end
  end

  def test_docx_package_includes_a_valid_numbering_part
    Dir.mktmpdir do |temp_dir|
      output = Docxout.new(temp_dir)
      path = File.join(temp_dir, output.print("- one\n- two", 'volodya-lombrozo', 'gpt-3.5-turbo'))
      Zip::File.open(path) do |zip|
        assert(zip.find_entry('word/numbering.xml'))
        assert(zip.find_entry('word/_rels/document.xml.rels'))
      end
    end
  end
end
