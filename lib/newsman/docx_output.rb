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
    <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/></Types>
  XML

  # Package-level relationships, pointing at the main document part.
  RELS = <<~XML
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/></Relationships>
  XML

  FONT = 'Times New Roman'
  # Word expresses font size in half-points, so 12pt is 24.
  SIZE = '24'

  def initialize(root = '.')
    @root = root
  end

  def print(report, reporter, model)
    puts "Create a docx file in a directory #{@root}"
    path = File.join(@root, filename(reporter, model))
    Zip::File.open(path, create: true) do |zip|
      zip.get_output_stream('[Content_Types].xml') { |f| f.write(CONTENT_TYPES) }
      zip.get_output_stream('_rels/.rels') { |f| f.write(RELS) }
      zip.get_output_stream('word/document.xml') { |f| f.write(document_xml(report)) }
    end
    puts "Report was successfully printed to a #{path}"
    File.basename(path)
  end

  def filename(reporter, model)
    date = Time.new.strftime('%d.%m.%Y')
    model = model.gsub('.', '-')
    "#{date}.#{reporter}.#{model}.docx"
  end

  private

  def document_xml(report)
    body = paragraphs(report).map { |lines| paragraph_xml(lines) }.join
    <<~XML
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"><w:body>#{body}<w:sectPr/></w:body></w:document>
    XML
  end

  def paragraphs(report)
    report.to_s.split(/\n{2,}/).map { |paragraph| paragraph.split("\n") }
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
