# frozen_string_literal: true
require 'json'

class PullRequest
  attr_accessor :repository, :title, :description
  attr_reader :url

  def initialize(repository, title, description, url: 'undefined')
    @repository = repository
    @title = title
    @description = description
    @url = url
  end

  def to_json
    {
      title: @title,
      description: @description,
      repository: @repository,
      url: @url
    }.to_json
  end

  def to_s
    "title: ```#{@title}```,\ndescription: ```#{@description}```,\nrepo: ```#{@repository}```\n"
  end

  def detailed_title
    "title: #{@title}, repo: #{@repository}, url: #{@url}"
  end

end
