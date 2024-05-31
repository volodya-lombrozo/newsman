#!/usr/bin/env ruby
# frozen_string_literal: true

class Report
  def initialize(user, position, title, additional: ReportItems.new([],[]))
    @user = user
    @position = position
    @title = title
    @additional = additional
  end

  def build(achievements, plans, risks, date)
    start = <<~TEMPLATE
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
    TEMPLATE
    finish = ''
    if !@additional.empty?
      finish = "\n------\n" + @additional.to_s
    end
    return start + finish;
  end
end

def week_of_a_year(project, today)
  number = today.strftime('%U').to_i + 1
  "WEEK #{number} #{project}"
end


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
    return "Closed Pull Requests:\n#{prs_list}\nOpen Issues:\n#{issues_list}"
  end
end
