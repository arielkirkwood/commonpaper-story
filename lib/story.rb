require "erb"
require "json"
require "thor"

class Story < Thor
  TEMPLATE = "One day Anna was walking her <%= number %> <%= unit_of_measure %> commute to <%= place %> and found a <%= adjective %> <%= noun %> on the ground."

  desc "generate STRING", "compose a story with a STRING that should be valid JSON (escaped if necessary for wrapping in a single set of quotes)"

  def generate(string)
    JSON.parse(string, symbolize_names: true) => {number:, unit_of_measure:, place:, adjective:, noun:}
    puts ERB.new(TEMPLATE).result(binding)
  rescue JSON::ParserError
    puts "The provided JSON input is invalid."
  end
end
