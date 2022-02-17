require "story"

RSpec.describe Story do
  let(:number) { 2 }
  let(:unit_of_measure) { "mile" }
  let(:place) { "school" }
  let(:adjective) { "blue" }
  let(:noun) { "rock" }
  let(:json) do
    {
      number: number,
      unit_of_measure: unit_of_measure,
      place: place,
      adjective: adjective,
      noun: noun
    }.to_json
  end
  let(:expected_story) { "One day Anna was walking her #{number} #{unit_of_measure} commute to #{place} and found a #{adjective} #{noun} on the ground.\n" }

  describe "#generate" do
    specify { expect { subject.generate(json) }.to output(expected_story).to_stdout }

    describe "JSON input edge cases" do
      describe "parsing failure" do
        let(:json) { '["test" : 123]' }

        specify { expect { subject.generate(json) }.to output("The provided JSON input failed to parse.\n").to_stdout }
      end

      describe "missing properties required by the template" do
        let(:json) do
          {
            unit_of_measure: unit_of_measure,
            place: place,
            adjective: adjective,
            noun: noun
          }.to_json
        end

        specify { expect { subject.generate(json) }.to output("The provided JSON is valid, but one or more of your inputs is missing.\n").to_stdout }
      end
    end
  end
end
