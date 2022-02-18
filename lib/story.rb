require "active_support"
require "csv"
require "erb"
require "json"
require "thor"

class ValidationError < StandardError
end

class Story < Thor
  COLUMN_HEADER_LABELS = [:number, :unit_of_measure, :place, :adjective, :noun]
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
    puts "Highest `number`: #{table.max_by { |row| row[:number] }[:number]}"
    puts ""
    puts "Lowest `number`: #{table.min_by { |row| row[:number] }[:number]}"
    puts ""
    puts "Most frequent `unit_of_measure`: #{mode(:unit_of_measure, table)}"
    puts ""
    puts "Most frequent `place`: #{mode(:place, table)}"
    puts ""
    puts "Most frequent `adjective`: #{mode(:adjective, table)}"
    puts ""
    puts "Most frequent `noun`: #{mode(:noun, table)}"
  end

  private

  def mode(column, table)
    candidate_values = table.values_at(column).flatten.uniq
    return candidate_values.first if candidate_values.one?

    candidate_appearances = candidate_values.map { |value| table.group_by { |row| row[column] }[value].length }

    candidate_values.first
    # candidate_values.zip(candidate_appearances).
  end

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
    table = CSV.table(STORIES_FILE)
    table << [number, unit_of_measure, place, adjective, noun]

    CSV.open(STORIES_FILE, "w+", write_headers: true, headers: COLUMN_HEADER_LABELS) do |file|
      table.each { |row| file.add_row(row) }
    end
  end
end
