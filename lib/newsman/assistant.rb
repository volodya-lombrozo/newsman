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
    return send("Please compile a summary of the plans for the next week using the following GitHub Issues descriptions. Each issue should be summarized in a single sentence, focusing more on the issue title and less on implementation details. Pay attention, that you didn't loose any issue. Ensure that each sentence includes the corresponding issue number as an integer value. If an issue doesn't mention an issue number, just print [#chore]. Combine all the information from each Issue into a concise and fluent sentences, as if you were a developer reporting on your work. Please strictly adhere to the example template provided: ```#{example}```. List of GitHub issues to aggregate: [#{issues}].")
  end

  def prev_results(prs)
    example = "repository-name:\n
      - Added 100 new files to the Dataset [#168]\n
      - Fixed the deployment of XYZ [#169]\n
      - Refined the requirements [#177]\n"
    return send("Please compile a summary of the work completed in the following Pull Requests (PRs). Each PR should be summarized in a single sentence, focusing more on the PR title and less on implementation details. Pay attention, that you don't lose any PR. Ensure that each sentence includes the corresponding issue number as an integer value. If a PR doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided: ```#{example}```. List of Pull Requests: [#{prs}]")
  end

  def risks(all)
    example = "repository-name:\n
      - The server is weak, we may fail the delivery\n
      of the dataset, report milestone will be missed [#487].\n
      - The code in repository is suboptimal, we might have some problems for the future maintainability [#44].\n"
    return send("Please compile a summary of the risks identified in the repository. If you can't find anything, just answer 'No risks identified'. Developers usually mention some risks in pull request descriptions. They either mention 'risk' or 'issue'. I will give you a list of pull requests. Each risk should be summarized in a single sentence. Ensure that each sentence includes the corresponding PR number as an integer value. If a PR doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided: ```#{example}```. List of Pull Requests: [#{all}]") 
  end

  def old_prev_results(prs)
    deprecated(__method__)
    example = "some-repository-name-x:
    - Added 100 new files to the Dataset [#168]
    - Fixed the deployment of XYZ [#169]
    - Refined the requirements [#177]
    some-repository-name-y:
    - Removed XYZ class [#57]
    - Refactored http module [#69]"
    response = @client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system',
            content: 'You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.' },
          { role: 'user',
            content: "Please compile a summary of the work completed in the following Pull Requests (PRs). Each PR should be summarized in a single sentence, focusing more on the PR title and less on implementation details. Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the PR. Pay attention, that you don't lose any PR. The grouping is important an should be precise. Ensure that each sentence includes the corresponding issue number as an integer value. If a PR doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided. Example of a report: #{example}. List of Pull Requests: [#{prs}]" }
        ],
        temperature: 0.3
      }
    )
    answer = response.dig('choices', 0, 'message', 'content')
    return answer 
  end

  def old_next_plans(issues)
    deprecated(__method__)
    example_plans = "some-repository-name-x:
    - To publish ABC package draft [#27]
    - To review first draft of the report [#56]
    some-repository-name-y:
    - To implement optimization for the class X [#125]"
    issues_response = openai_client.chat(
      parameters: {
        model: 'gpt-3.5-turbo',
        messages: [
          { role: 'system',
            content: 'You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.' },
          { role: 'user',
            content: "Please compile a summary of the plans for the next week using the following GitHub Issues descriptions. Each issue should be summarized in a single sentence, focusing more on the issue title and less on implementation details. Group the sentences by repositories, each identified by its name mentioned in the 'repository:[name]' attribute of the issue. Pat attention, that you din't loose any issue. The grouping is important an should be precise. Ensure that each sentence includes the corresponding issue number as an integer value. If an issue doesn't mention an issue number, just print [#chore]. Combine all the information from each Issue into a concise and fluent sentences, as if you were a developer reporting on your work. Please strictly adhere to the example template provided: #{example_plans}. List of GitHub issues to aggregate: [#{issues}]." }
        ],
        temperature: 0.3
      }
    )
    issues_full_answer = issues_response.dig('choices', 0, 'message', 'content')
    return issues_full_answer
  end 

  def old_risks(all)
    deprecated(__method__)
    example_risks = "some-repository-name-x:
  - The server is weak, we may fail the delivery
  of the dataset, report milestone will be missed [#487].
some-repository-name-y:
  - The code in repository is suboptimal, we might have some problems for the future maintainability [#44]."
    return openai_client.chat(
        parameters: {
          model: 'gpt-3.5-turbo',
          messages: [
            { role: 'system',
              content: 'You are a developer tasked with composing a concise report detailing your activities and progress for the previous week, intended for submission to your supervisor.' },
            { role: 'user',
              content: "Please compile a summary of the risks identified in some repositories. If you can't find anything, just leave answer empty. Add some entries to a report only if you are sure it's a risk. Developers usually mention some risks in pull request descriptions. They either mention 'risk' or 'issue'. I will give you a list of pull requests. Each risk should be summarized in a single sentence. Ensure that each sentence includes the corresponding issue number or PR number as an integer value. If a PR or an issue doesn't mention an issue number, just print [#chore]. Combine all the information from each PR into a concise and fluent sentence, as if you were a developer reporting on your work. Please strictly adhere to the example template provided. Example of a report: #{example_risks}. List of Pull Requests: ```#{all}```.]" }
          ],
          temperature: 0.3
        }
      ).dig('choices', 0, 'message', 'content')
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

  def deprecated(method)
    warn "Warning! '#{method}' is deprecated and will be removed in future versions."
  end

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

  def deprecated(method)
    warn "Warning! '#{method}' is deprecated and will be removed in future versions."
  end

end
