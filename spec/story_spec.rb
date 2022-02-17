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

        specify { expect { subject.generate(json) }.to output("The provided JSON is valid, but one or more of your inputs is missing in the JSON body.\n").to_stdout }
      end
    end

    describe "additional validations on story inputs" do
      describe "number" do
        context "when non-numeric" do
          let(:number) { "a" }

          specify { expect { subject.generate(json) }.to output("The `number` input is not a number.\n").to_stdout }
        end

        context "when blank" do
          let(:number) { "" }

          specify { expect { subject.generate(json) }.to output("The `number` input is blank.\n").to_stdout }
        end

        context "when too many digits" do
          let(:number) { 9999 }

          specify { expect { subject.generate(json) }.to output("The `number` input is too long.\n").to_stdout }
        end
      end

      describe "unit of measure" do
        context "when blank" do
          let(:unit_of_measure) { "" }

          specify { expect { subject.generate(json) }.to output("The `unit_of_measure` input is blank.\n").to_stdout }
        end

        context "when too long" do
          let(:unit_of_measure) { "miles and miles" }

          specify { expect { subject.generate(json) }.to output("The `unit_of_measure` input is too long.\n").to_stdout }
        end
      end

      describe "place" do
        context "when blank" do
          let(:place) { "" }

          specify { expect { subject.generate(json) }.to output("The `place` input is blank.\n").to_stdout }
        end

        context "when too long" do
          let(:place) { "a place that exceeds my imagination" }

          specify { expect { subject.generate(json) }.to output("The `place` input is too long.\n").to_stdout }
        end
      end

      describe "adjective" do
        context "when blank" do
          let(:adjective) { "" }

          specify { expect { subject.generate(json) }.to output("The `adjective` input is blank.\n").to_stdout }
        end

        context "when too long" do
          let(:adjective) { "supercalifragilistic" }

          specify { expect { subject.generate(json) }.to output("The `adjective` input is too long.\n").to_stdout }
        end
      end

      describe "noun" do
        context "when blank" do
          let(:noun) { "" }

          specify { expect { subject.generate(json) }.to output("The `noun` input is blank.\n").to_stdout }
        end

        context "when too long" do
          let(:noun) { "antidisestablishmentarianism" }

          specify { expect { subject.generate(json) }.to output("The `noun` input is too long.\n").to_stdout }
        end
      end
    end
  end
end
