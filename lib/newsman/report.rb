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
    start = "From: #{@user}\nSubject: #{week_of_a_year(@title,
                                               date)}\n\nHi all,\n\nLast week achievements:\n#{achievements}\n\nNext week plans:\n#{plans}\n\nRisks:\n#{risks}\n\nBest regards,\n#{@user}\n#{@position}\n#{date}"

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
