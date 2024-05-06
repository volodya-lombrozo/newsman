require 'openai'

class Assistant
  def initialize(token, model: 'gpt-3.5-turbo', temperature: 0.3)
    @token = token
    @model = model
    @temperature = temperature
    @client = OpenAI::Client.new(access_token: token)
  end
end
