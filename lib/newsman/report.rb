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

# This class builds entire report based on issues and pull requests passed.
class Report
  def initialize(user, position, title, additional: ReportItems.new([], []))
    @user = user
    @position = position
    @title = title
    @additional = additional
  end

  def build(achievements, plans, risks, date)
    <<~TEMPLATE.chomp
      From: #{@user}
      Subject: #{week_of_a_year(@title, date)}

      Hi all,

      Last week achievements:
      #{achievements}

      Next week plans:
      #{plans}

      Risks:
      #{risks}

      Best regards,
      #{@user}
      #{@position}
      #{date}
      #{"------\n#{@additional}" unless @additional.empty?}
    TEMPLATE
  end
end

def week_of_a_year(project, today)
  number = today.strftime('%U').to_i + 1
  "WEEK #{number} #{project}"
end

# Report items inner class.
class ReportItems
  def initialize(prs, issues)
    @prs = prs || []
    @issues = issues || []
  end

  # Returns true if there are no pull requests or issues, false otherwise
  def empty?
    @prs.empty? && @issues.empty?
  end

  def to_s
    prs_list = @prs.map(&:detailed_title).map { |obj| " - #{obj}\n" }.join
    issues_list = @issues.map(&:detailed_title).map { |obj| " - #{obj}\n" }.join
    "Closed Pull Requests:\n#{prs_list}\nOpen Issues:\n#{issues_list}"
  end
end
