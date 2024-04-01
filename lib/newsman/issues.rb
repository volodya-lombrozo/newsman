require 'net/http'
# frozen_string_literal: true

class Issue 
  attr_accessor :title, :body, :repo, :number

  def initialize(title, body, repo, number)
    @title = title
    @body = body
    @repo = repo
    @number = number
  end

  def to_s
    "title: ```#{@title}```,\ndescription: ```#{@body}```,\nrepo: ```#{@repo}```,\nissue number: \##{@number}\n"
  end
end

class PddIssue

  def initialize(title, body, repo, number)
    @title = title
    @body = body
    @repo = repo
    @number = number
  end

  def extract_real_body
    address = issue_link()
    puts "Pdd issue link where we search for the body: #{address}"
    uri = URI(address)
    return Net::HTTP.get(uri).lines.size
  end

  def issue_link 
    return @body[/https:\/\/github\.com\/[\w\-\/]+\/blob\/[\w\d]+\/[\w\/\.\-]+#\w+-\w+/, 0].gsub('https://github.com','https://raw.githubusercontent.com').gsub('blob/', '')
  end


  def to_s
    "title: ```#{@title}```,\ndescription: ```#{extract_real_body}```,\nrepo: ```#{@repo}```,\nissue number: \##{@number}\n"
  end
end

