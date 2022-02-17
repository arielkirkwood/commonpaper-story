require "story"

RSpec.describe Story do
  let(:number) { 2 }
  let(:unit_of_measure) { "mile" }
  let(:place) { "school" }
  let(:adjective) { "blue" }
  let(:noun) { "rock" }
  let(:json) do
    <<~JSON
      {
        "number": #{number},
        "unit_of_measure": "#{unit_of_measure}",
        "place": "#{place}",
        "adjective": "#{adjective}",
        "noun": "#{noun}"
      }
    JSON
  end
  let(:expected_story) { "One day Anna was walking her 2 mile commute to school and found a blue rock on the ground.\n" }

  describe "#generate" do
    specify { expect { subject.generate(json) }.to output(expected_story).to_stdout }

    context "with an invalid JSON input" do
      let(:json) { '["test" : 123]' }

      specify { expect { subject.generate(json) }.to output("The provided JSON input is invalid.\n").to_stdout }
    end
  end
end
