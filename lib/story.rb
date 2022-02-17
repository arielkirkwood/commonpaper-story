require "active_support"
require "csv"
require "erb"
require "json"
require "thor"

class ValidationError < StandardError
end

class Story < Thor
  STORIES_FILE = "public/stories.csv"
  TEMPLATE = "One day Anna was walking her <%= number %> <%= unit_of_measure %> commute to <%= place %> and found a <%= adjective %> <%= noun %> on the ground."

  desc "generate STRING", "compose a story with a STRING that should be valid JSON (escaped if necessary for wrapping in a single set of quotes)"

  def generate(string)
    JSON.parse(string, symbolize_names: true) => {number:, unit_of_measure:, place:, adjective:, noun:}
    validate(number, unit_of_measure, place, adjective, noun)
    persist(number, unit_of_measure, place, adjective, noun)

    puts ERB.new(TEMPLATE).result(binding)
  rescue JSON::ParserError
    puts "The provided JSON input failed to parse."
  rescue NoMatchingPatternError
    puts "The provided JSON is valid, but one or more of your inputs is missing in the JSON body."
  rescue ValidationError => e
    puts e.message
  end

  desc "statistics", "view summary statistics of the data in #{STORIES_FILE}"

  def statistics
    table = CSV.table(STORIES_FILE)

    puts "Statistics on #{table.size} stored records:"
    puts ""
    puts "Highest `number`:"
    puts ""
    puts "Lowest `number`:"
    puts ""
    puts "Most frequent `unit_of_measure`:"
    puts ""
    puts "Most frequent `place`:"
    puts ""
    puts "Most frequent `adjective`:"
    puts ""
    puts "Most frequent `noun`:"
  end

  private

  def validate(number, unit_of_measure, place, adjective, noun)
    raise ValidationError, "The `number` input is blank." if number.blank?
    raise ValidationError, "The `unit_of_measure` input is blank." if unit_of_measure.blank?
    raise ValidationError, "The `place` input is blank." if place.blank?
    raise ValidationError, "The `adjective` input is blank." if adjective.blank?
    raise ValidationError, "The `noun` input is blank." if noun.blank?

    raise ValidationError, "The `number` input is not a number." unless number.is_a?(Integer)

    raise ValidationError, "The `number` input is too long." if number.to_s.length > 3
    raise ValidationError, "The `unit_of_measure` input is too long." if unit_of_measure.length > 10
    raise ValidationError, "The `place` input is too long." if place.length > 20
    raise ValidationError, "The `adjective` input is too long." if adjective.length > 15
    raise ValidationError, "The `noun` input is too long." if noun.length > 15
  end

  def persist(number, unit_of_measure, place, adjective, noun)
    CSV.open(STORIES_FILE, "a", write_headers: true) do |file|
      file.add_row([number, unit_of_measure, place, adjective, noun])
    end
  end
end
