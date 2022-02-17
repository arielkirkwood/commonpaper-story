require "erb"
require "thor"

class Story < Thor
  TEMPLATE = "One day Anna was walking her <%= number %> <%= unit_of_measure %> commute to <%= place %> and found a <%= adjective %> <%= noun %> on the ground."

  desc "story JSON", "compose a story with JSON"

  def story
    puts ERB.new(TEMPLATE).result(binding)
  end

  private

  def number
    2
  end

  def unit_of_measure
    "mile"
  end

  def place
    "school"
  end

  def adjective
    "blue"
  end

  def noun
    "rock"
  end
end

Story.start(ARGV)
