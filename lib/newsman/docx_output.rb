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

require 'zip'
require 'cgi'

# This class represents a report output in DOCX (MS Word) format.
# It builds a minimal, valid OOXML package by hand (no external docx-builder
# gem), so every run of text is explicitly styled with Times New Roman, 12pt.
class Docxout
  # Content types part, required by every OOXML package.
  CONTENT_TYPES = <<~XML
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/><Override PartName="/word/numbering.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"/></Types>
  XML

  # Package-level relationships, pointing at the main document part.
  RELS = <<~XML
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
  XML

  # Document-level relationships, pointing at the numbering part used by lists.
  DOCUMENT_RELS = <<~XML
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering" Target="numbering.xml"/></Relationships>
  XML

  # Numbering definitions: numId 1 is a bulleted list, numId 2 is a decimal (numbered) list.
  NUMBERING = <<~XML
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <w:numbering xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:abstractNum w:abstractNumId="0"><w:lvl w:ilvl="0"><w:numFmt w:val="bullet"/><w:lvlText w:val="&#8226;"/><w:pPr><w:ind w:left="720" w:hanging="360"/></w:pPr></w:lvl></w:abstractNum><w:abstractNum w:abstractNumId="1"><w:lvl w:ilvl="0"><w:numFmt w:val="decimal"/><w:lvlText w:val="%1."/><w:pPr><w:ind w:left="720" w:hanging="360"/></w:pPr></w:lvl></w:abstractNum><w:num w:numId="1"><w:abstractNumId w:val="0"/></w:num><w:num w:numId="2"><w:abstractNumId w:val="1"/></w:num></w:numbering>
  XML

  # Matches markdown headers, e.g. "## Title" (levels 1-6).
  HEADING = /^\s{0,3}(\#{1,6})\s+(.+?)\s*$/
  # Matches markdown bullet list items, e.g. "- item" or "* item".
  BULLET = /^\s{0,3}[-*]\s+(.+?)\s*$/
  # Matches markdown numbered list items, e.g. "1. item".
  NUMBERED = /^\s{0,3}\d+\.\s+(.+?)\s*$/

  FONT = 'Times New Roman'
  # Word expresses font size in half-points, so 12pt is 24.
  SIZE = '24'

  def initialize(root = '.')
    @root = root
  end

  def print(report, reporter, model)
    puts "Create a docx file in a directory #{@root}"
    path = File.join(@root, filename(reporter, model))
    write_package(path, report)
    puts "Report was successfully printed to a #{path}"
    File.basename(path)
  end

  def filename(reporter, model)
    date = Time.new.strftime('%d.%m.%Y')
    model = model.gsub('.', '-')
    "#{date}.#{reporter}.#{model}.docx"
  end

  private

  def write_package(path, report)
    Zip::File.open(path, create: true) do |zip|
      zip.get_output_stream('[Content_Types].xml') { |f| f.write(CONTENT_TYPES) }
      zip.get_output_stream('_rels/.rels') { |f| f.write(RELS) }
      zip.get_output_stream('word/_rels/document.xml.rels') { |f| f.write(DOCUMENT_RELS) }
      zip.get_output_stream('word/numbering.xml') { |f| f.write(NUMBERING) }
      zip.get_output_stream('word/document.xml') { |f| f.write(document_xml(report)) }
    end
  end

  def document_xml(report)
    body = blocks(report).map { |block| block_xml(block) }.join
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>#{body}<w:sectPr/></w:body></w:document>
    XML
  end

  # Splits the report into blocks: markdown headers and list items each become
  # their own block, and consecutive plain-text lines are grouped together.
  def blocks(report)
    classified = report.to_s.split("\n", -1).map { |line| classify(line) }
    classified.chunk_while { |prev, curr| prev[:type] == :text && curr[:type] == :text }
              .reject { |group| group.first[:type] == :blank }
              .map { |group| merge_text(group) }
  end

  def merge_text(group)
    return group.first unless group.first[:type] == :text

    { type: :text, lines: group.map { |block| block[:line] } }
  end

  def classify(line)
    return { type: :blank } if line.strip.empty?
    return { type: :heading, level: ::Regexp.last_match(1).length, text: ::Regexp.last_match(2) } if line =~ HEADING
    return { type: :bullet, text: ::Regexp.last_match(1) } if line =~ BULLET
    return { type: :numbered, text: ::Regexp.last_match(1) } if line =~ NUMBERED

    { type: :text, line: line }
  end

  def block_xml(block)
    case block[:type]
    when :heading
      "<w:p><w:pPr><w:pStyle w:val=\"Heading#{block[:level]}\"/></w:pPr>#{run_xml(block[:text])}</w:p>"
    when :bullet
      list_item_xml(block[:text], '1')
    when :numbered
      list_item_xml(block[:text], '2')
    else
      paragraph_xml(block[:lines])
    end
  end

  def list_item_xml(text, num_id)
    "<w:p><w:pPr><w:numPr><w:ilvl w:val=\"0\"/><w:numId w:val=\"#{num_id}\"/></w:numPr></w:pPr>#{run_xml(text)}</w:p>"
  end

  def paragraph_xml(lines)
    runs = lines.each_with_index.map do |line, index|
      "#{run_xml(line)}#{'<w:r><w:br/></w:r>' if index < lines.size - 1}"
    end.join
    "<w:p>#{runs}</w:p>"
  end

  def run_xml(line)
    "<w:r><w:rPr><w:rFonts w:ascii=\"#{FONT}\" w:hAnsi=\"#{FONT}\" w:cs=\"#{FONT}\"/>" \
      "<w:sz w:val=\"#{SIZE}\"/><w:szCs w:val=\"#{SIZE}\"/></w:rPr>" \
      "<w:t xml:space=\"preserve\">#{CGI.escapeHTML(line)}</w:t></w:r>"
  end
end
