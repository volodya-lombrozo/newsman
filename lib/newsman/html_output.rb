require 'erb'
# frozen_string_literal: true

class Htmlout

  TEMPLATE = "<!DOCTYPE html>
<html lang=\"en\">
<head>
  <meta charset=\"UTF-8\">
  <title><%= title %></title>
</head>
<body>
  <h1><%= title %></h1>
  <p><%= body %></p>
</body>
</html>
"

  def initialize(root = '.')
    @root = root
  end
  
  def print(report, reporter)
    title = title(reporter) 
    body = report
    renderer = ERB.new(TEMPLATE)
    html_content = renderer.result(binding)
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
