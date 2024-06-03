# frozen_string_literal: true

# Copyright (c) 2024 Volodya Lombrozo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'openai'

# This class mimics a robot that can analyse a developer activity.
# The assistant uses OpenAI API to analyze.
class Assistant
  CONTEXT = 'You are a developer tasked'\
  ' with composing a concise report detailing your activities'\
  ' and progress for the previous week,'\
  ' intended for submission to your supervisor.'

  def initialize(token, model: 'gpt-3.5-turbo', temperature: 0.3)
    @token = token
    @model = model
    @temperature = temperature
    @client = OpenAI::Client.new(access_token: token)
  end

  def say_hello
    <<~HELLO
      I'm an assistant that can work with OpenAI client.
      Please, use me, if you need any help.
      I'm using #{@model}, with #{@temperature} temperature.
    HELLO
  end

  # rubocop:disable Metrics/MethodLength
  def next_plans(issues)
    example = "repository-name:\n
      - To publish ABC package draft [#27]\n
      - To review first draft of the report [#56]\n
      - To implement optimization for the class X [#125]"
    prompt = <<~PROMPT
      Please compile a summary of the plans for the next week using the GitHub Issues.
      Each issue should be summarized in a single sentence, focusing more on the issue title and less on implementation details.
      Combine all the information from each Issue into a concise and fluent sentence.
      Pay attention, that you didn't loose any issue.
      Ensure that each sentence includes the corresponding issue number as an integer value. If an issue doesn't mention an issue number, just print [#chore].
      If several issues have the same number, combine them into a single sentence.
      Please strictly adhere to the example template provided: "#{example}".
      List of GitHub Issues in JSON format: ```json #{issues}```.
    PROMPT
    send(prompt)
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def prev_results(prs)
    example = "repository-name:\n
      - Added 100 new files to the Dataset [#168]\n
      - Fixed the deployment of XYZ [#169]\n
      - Refined the requirements [#177]\n"
    prompt = <<~PROMPT
      Please compile a summary of the work completed in the following Pull Requests (PRs).
      Each PR should be summarized in a single sentence, focusing on the PR title rather than the implementation details.
      Ensure no PR is omitted.
      Each sentence must include the corresponding issue number as an integer value. If a PR does not mention an issue number, use [#chore].
      If several PRs have the same number, combine them into a single sentence.
      Combine the information from each PR into a concise and fluent sentence.
      Follow the provided example template strictly: "#{example}".
      List of Pull Requests in JSON format: ```json #{prs}```.
    PROMPT
    send(prompt)
  end
  # rubocop:enable Metrics/MethodLength

  # rubocop:disable Metrics/MethodLength
  def risks(all)
    example = "repository-name:\n
      - The server is weak, we may fail the delivery\n
      of the dataset, report milestone will be missed [#487].\n
      - The code in repository is suboptimal, we might have some problems for the future maintainability [#44].\n"
    prompt = <<~PROMPT
      Please compile a summary of the risks identified in the repository from the list of pull requests provided.
      If no risks are identified in a pull request, just answer 'No risks identified' for that PR.
      Each risk should be summarized in a concise and fluent single sentence.
      Developers usually mention some risks in pull request descriptions, either as 'risk' or 'issue'.#{' '}
      Ensure that each sentence includes the corresponding PR number as an integer value. If a PR doesn't mention an issue number, just print [#chore].
      Please strictly adhere to the example template provided: "#{example}".
      List of Pull Requests: ```json #{all}```.
    PROMPT
    send(prompt)
  end
  # rubocop:enable Metrics/MethodLength

  def send(request)
    @client.chat(
      parameters: {
        model: @model,
        messages: [
          { role: 'system', content: CONTEXT },
          { role: 'user', content: request.to_s }
        ],
        temperature: @temperature
      }
    ).dig('choices', 0, 'message', 'content')
  end

  def deprecated(method)
    warn "Warning! '#{method}' is deprecated and will be removed in future versions."
  end
end
