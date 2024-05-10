require 'openai'

class Assistant

  CONTEXT = 'You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.' 



  def initialize(token, model: 'gpt-3.5-turbo', temperature: 0.3)
    @token = token
    @model = model
    @temperature = temperature
    @client = OpenAI::Client.new(access_token: token)
  end

  def say_hello
    "I'm an assistant that can work with OpenAI client. Please, use me, if you need any help. I'm using #{@model}, with #{@temperature} temperature."
  end

  def next_plans(issues)
    example = "repository-name:\n
      - To publish ABC package draft [#27]\n
      - To review first draft of the report [#56]\n
      - To implement optimization for the class X [#125]"
    return send("Please compile a summary of the plans for the next week using the following GitHub Issues descriptions. Each issue should be summarized in a single sentence, focusing more on the issue title and less on implementation details. Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the issue. Pat attention, that you din't loose any issue. The grouping is important an should be precise. Ensure that each sentence includes the corresponding issue number as an integer value. If an issue doesn't mention an issue number, just print [#chore]. Combine all the information from each Issue into a concise and fluent sentences, as if you were a developer reporting on your work. Please strictly adhere to the example template provided: #{example}. List of GitHub issues to aggregate: [#{issues}].")
  end

  def prev_results(prs)
    ""
  end

  def risks(all)
    ""
  end

  def send(request)
    return @client.chat(
      parameters: {
        model: @model,
        messages: [
          { role: 'system',
            content: CONTEXT },
          { role: 'user',
            content: "#{request}" } 
        ],
        temperature: @temperature
      }
    ).dig('choices', 0, 'message', 'content')
  end


end
