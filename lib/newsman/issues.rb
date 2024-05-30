# frozen_string_literal: true

require 'net/http'
require 'json'

class Issue
  attr_accessor :title, :body, :repo, :number
  attr_reader :url

  def initialize(title, body, repo, number, url: 'undefined')
    @title = title
    @body = body
    @repo = repo
    @number = number
    @url = url
  end

  def to_s
    "title: ```#{@title}```,\ndescription: ```#{@body}```,\nrepo: ```#{@repo}```,\nissue number: \##{@number}\n"
  end

  def detailed_title 
    "title: #{@title}, repo: #{@repo}, number: \##{@number}, url: #{@url}"
  end

  def to_json
    {
      number: @number,
      title: @title,
      description: @body,
      repository: @repo,
      url: @url
    }.to_json
  end
    
end

class PddIssue
  attr_accessor :repo

  def initialize(title, body, repo, number, url: 'undefined')
    @title = title
    @body = body
    @repo = repo
    @number = number
    @url = url 
  end

  def extract_real_body
    address = issue_link
    line_numbers = address.scan(/#L(\d+)-L(\d+)/).flatten.map(&:to_i)
    uri = URI(address)
    Net::HTTP.get(uri).lines[line_numbers[0] - 1..line_numbers[1]]
  end

  def issue_link
    @body[%r{https://github\.com/[\w\-/]+/blob/[\w\d]+/[\w/.-]+#\w+-\w+}, 0].gsub('https://github.com', 'https://raw.githubusercontent.com').gsub(
      'blob/', ''
    )
  end

  def to_s
    "title: ```#{@title}```,\ndescription: ```#{extract_real_body}```,\nrepo: ```#{@repo}```,\nissue number: \##{@number}\n"
  end

  def detailed_title
    "title: #{@title}, repo: #{@repo}, issue number: \##{@number}, url: #{@url}"
  end

  def to_json
    {
      number: @number,
      title: @title,
      description: @body,
      repository: @repo,
      url: @url
    }.to_json
  end

end
