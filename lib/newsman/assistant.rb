require 'openai'

class Assistant
  def initialize(token, model: 'gpt-3.5-turbo', temperature: 0.3)
    @token = token
    @model = model
    @temperature = temperature
    @client = OpenAI::Client.new(access_token: token)
  end

  def say_hello
    "I'm an assistant that can work with OpenAI client. Please, use me, if you need any help. I'm using #{@model}, with #{@temperature} temperature."
  end
end
