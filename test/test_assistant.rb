#!/usr/bin/env ruby
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

require 'minitest/autorun'
require_relative '../lib/newsman/assistant'

class TestAssistant < Minitest::Test
  def test_creates_default_assistant
    assistant = Assistant.new('test-token')
    expected = <<~EXPECTED
      I'm an assistant that can work with OpenAI client.
      Please, use me, if you need any help.
      I'm using gpt-3.5-turbo, with 0.3 temperature.
    EXPECTED
    assert_equal expected,
                 assistant.say_hello
  end

  def test_fixed_temperature_for_reasoning_models
    %w[o1 o1-preview o1-mini o3 o3-mini o4-mini gpt-5 gpt-5-mini gpt-5.6].each do |model|
      assistant = Assistant.new('test-token', model: model)
      assert(assistant.fixed_temperature?, "expected #{model} to have a fixed temperature")
    end
  end

  def test_custom_temperature_for_chat_models
    %w[gpt-3.5-turbo gpt-4o gpt-4.1 gpt-5-chat-latest].each do |model|
      assistant = Assistant.new('test-token', model: model)
      refute(assistant.fixed_temperature?, "expected #{model} to allow a custom temperature")
    end
  end

  def test_o1_preview_skips_system_message
    assistant = Assistant.new('test-token', model: 'o1-preview')
    messages = assistant.messages('do something')
    assert_equal([{ role: 'user', content: 'do something' }], messages)
  end

  def test_other_models_keep_system_message
    assistant = Assistant.new('test-token', model: 'gpt-5.6')
    messages = assistant.messages('do something')
    assert_equal(2, messages.size)
    assert_equal('system', messages.first[:role])
  end
end
