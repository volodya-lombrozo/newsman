class PullRequest
  attr_accessor :repository, :title, :description

  def initialize(repository, title, description)
    @repository = repository
    @title = title
    @description = description
  end

  def to_s
    "title: ```#{@title}```\n, description: ```#{@description}```\n, repo: ```#{@repository}```\n"
  end
end
