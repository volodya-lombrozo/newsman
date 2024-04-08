#!/usr/bin/env ruby

class Report
  def initialize(user, position, title)
    @user = user
    @position = position
    @title = title
  end
  def build(achievements, plans, risks, date)
    return "From: #{@user}\nSubject: #{week_of_a_year(@title, date)}\n\nHi all,\n\nLast week achievements:\n#{achievements}\n\nNext week plans:\n#{plans}\n\nRisks:\n#{risks}\n\nBest regards,\n#{@user}\n#{@position}\n#{date}"
  end
end

def week_of_a_year(project, today)
  number = today.strftime('%U').to_i + 1
  "WEEK #{number} #{project}"
end

