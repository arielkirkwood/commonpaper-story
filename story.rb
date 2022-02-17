require "thor"

class Story < Thor
  desc "story JSON", "compose a story with JSON"

  def story(json)
    puts template(json)
  end

  private

  def template(json)
    <<~STORY
      One day Anna was walking her #{number} #{unit_of_measure} commute to #{place} and found a #{adjective} #{noun} on the ground.
    STORY
  end

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
