# frozen_string_literal: true

class PullRequest
  attr_accessor :repository, :title, :description

  def initialize(repository, title, description)
    @repository = repository
    @title = title
    @description = description
  end

  def to_s
    "title: ```#{@title}```,\ndescription: ```#{@description}```,\nrepo: ```#{@repository}```\n"
  end
end
