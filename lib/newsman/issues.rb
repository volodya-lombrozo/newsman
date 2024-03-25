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

