require 'erb'
require 'redcarpet'
require 'nokogiri'
# frozen_string_literal: true

class Htmlout

  TEMPLATE = "
<head>
  <title><%= title %></title>
</head>
<body>
  <h1><%= title %></h1>
  <%= body %>
</body>
"

  def initialize(root = '.')
    @root = root
  end
  
  def print(report, reporter)
    title = title(reporter) 
    renderer = Redcarpet::Render::HTML.new(no_links: true, hard_wrap: true, prettify: true)
    markdown = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)
    body = markdown.render(report)
    renderer = ERB.new(TEMPLATE)
    html_content = renderer.result(binding)
    html_content = Nokogiri::HTML(html_content, &:noblanks).to_xhtml(indent: 2)
    puts "Create a html file in a directory #{@root}"
    file = File.new(File.join(@root, filename(reporter)), 'w')
    puts "File #{file.path} was successfully created"
    file.puts html_content
    puts "Report was successfully printed to a #{file.path}"
    file.close
  end

  def title(reporter)
    date = Time.new.strftime('%d.%m.%Y')
    "#{reporter} #{date}"
  end

  def filename(reporter)
    date = Time.new.strftime('%d.%m.%Y')
    "#{date}.#{reporter}.html"
  end
end
