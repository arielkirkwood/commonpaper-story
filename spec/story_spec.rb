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
  let(:expected_story) { (/One day Anna was walking her #{number} #{unit_of_measure} commute to #{place} and found a #{adjective} #{noun} on the ground./) }

  describe "#generate" do
    it { expect { subject.generate(json) }.to output(expected_story).to_stdout }

    describe "JSON input edge cases" do
      describe "parsing failure" do
        let(:json) { '["test" : 123]' }

        it { expect { subject.generate(json) }.to output(/The provided JSON input failed to parse./).to_stdout }
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

        it { expect { subject.generate(json) }.to output(/The provided JSON is valid, but one or more of your inputs is missing in the JSON body./).to_stdout }
      end
    end

    describe "additional validations on story inputs" do
      describe "number" do
        context "when non-numeric" do
          let(:number) { "a" }

          it { expect { subject.generate(json) }.to output(/The `number` input is not a number./).to_stdout }
        end

        context "when blank" do
          let(:number) { "" }

          it { expect { subject.generate(json) }.to output(/The `number` input is blank./).to_stdout }
        end

        context "when too many digits" do
          let(:number) { 9999 }

          it { expect { subject.generate(json) }.to output(/The `number` input is too long./).to_stdout }
        end
      end

      describe "unit of measure" do
        context "when blank" do
          let(:unit_of_measure) { "" }

          it { expect { subject.generate(json) }.to output(/The `unit_of_measure` input is blank./).to_stdout }
        end

        context "when too long" do
          let(:unit_of_measure) { "miles and miles" }

          it { expect { subject.generate(json) }.to output(/The `unit_of_measure` input is too long./).to_stdout }
        end
      end

      describe "place" do
        context "when blank" do
          let(:place) { "" }

          it { expect { subject.generate(json) }.to output(/The `place` input is blank./).to_stdout }
        end

        context "when too long" do
          let(:place) { "a place that exceeds my imagination" }

          it { expect { subject.generate(json) }.to output(/The `place` input is too long./).to_stdout }
        end
      end

      describe "adjective" do
        context "when blank" do
          let(:adjective) { "" }

          it { expect { subject.generate(json) }.to output(/The `adjective` input is blank./).to_stdout }
        end

        context "when too long" do
          let(:adjective) { "supercalifragilistic" }

          it { expect { subject.generate(json) }.to output(/The `adjective` input is too long./).to_stdout }
        end
      end

      describe "noun" do
        context "when blank" do
          let(:noun) { "" }

          it { expect { subject.generate(json) }.to output(/The `noun` input is blank./).to_stdout }
        end

        context "when too long" do
          let(:noun) { "antidisestablishmentarianism" }

          it { expect { subject.generate(json) }.to output(/The `noun` input is too long./).to_stdout }
        end
      end
    end
  end

  describe "#statistics" do
    let(:csv_rows) { [CSV::Row.new(described_class::COLUMN_HEADER_LABELS, %w[2 mile school blue rock]),
                      CSV::Row.new(described_class::COLUMN_HEADER_LABELS, %w[2 mile school blue rock])] }

    before { allow(CSV).to receive(:table).with(described_class::STORIES_FILE).and_return(CSV::Table.new(csv_rows)) }

    it { expect { subject.statistics }.to output(/Statistics on 2 stored records:/).to_stdout }

    describe "number statistics" do
      it { expect { subject.statistics }.to output(/Highest `number`: 2/).to_stdout }
      it { expect { subject.statistics }.to output(/Lowest `number`: 2/).to_stdout }
    end

    describe "unit of length statistics" do
      it { expect { subject.statistics }.to output(/Most frequent `unit_of_measure`: mile/).to_stdout }
    end

    describe "place statistics" do
      it { expect { subject.statistics }.to output(/Most frequent `place`: school/).to_stdout }
    end

    describe "adjective statistics" do
      it { expect { subject.statistics }.to output(/Most frequent `adjective`: blue/).to_stdout }
    end

    describe "noun statistics" do
      it { expect { subject.statistics }.to output(/Most frequent `noun`: rock/).to_stdout }
    end

    context "multiple values represented with equal frequency" do
      let(:csv_rows) { [CSV::Row.new(described_class::COLUMN_HEADER_LABELS, %w[2 mile school blue rock]),
                        CSV::Row.new(described_class::COLUMN_HEADER_LABELS, %w[2 kilometer home red coin]),
                        CSV::Row.new(described_class::COLUMN_HEADER_LABELS, %w[2 nautical-mile shore green seaweed])] }

      describe "number statistics" do
        it { expect { subject.statistics }.to output(/Highest `number`: 2/).to_stdout }
        it { expect { subject.statistics }.to output(/Lowest `number`: 2/).to_stdout }
      end

      describe "unit of length statistics" do
        it { expect { subject.statistics }.to output(/Most frequent `unit_of_measure`: There is no mode./).to_stdout }
      end

      describe "place statistics" do
        it { expect { subject.statistics }.to output(/Most frequent `place`: There is no mode./).to_stdout }
      end

      describe "adjective statistics" do
        it { expect { subject.statistics }.to output(/Most frequent `adjective`: There is no mode./).to_stdout }
      end

      describe "noun statistics" do
        it { expect { subject.statistics }.to output(/Most frequent `noun`: There is no mode./).to_stdout }
      end
    end

    context "0 rows of data" do
      let(:csv_rows) { [] }

      it { expect { subject.statistics }.to output(/There are no stored records. Run `bin\/story generate` to create one!/).to_stdout }
    end

    context "42 rows of data" do
      let(:count) { 42 }
      let(:csv_rows) do
        rows = []
        (0..19).each { |index| rows.push(CSV::Row.new(described_class::COLUMN_HEADER_LABELS, [index] + %w[mile school blue rock])) }
        (20..41).each { |index| rows.push(CSV::Row.new(described_class::COLUMN_HEADER_LABELS, [index] + %w[kilometer home red coin])) }
        rows
      end

      it { expect { subject.statistics }.to output(/Statistics on #{count} stored records:/).to_stdout }

      describe "number statistics" do
        it { expect { subject.statistics }.to output(/Highest `number`: 41/).to_stdout }
        it { expect { subject.statistics }.to output(/Lowest `number`: 0/).to_stdout }
      end

      describe "unit of length statistics" do
        it { expect { subject.statistics }.to output(/Most frequent `unit_of_measure`: kilometer/).to_stdout }
      end

      describe "place statistics" do
        it { expect { subject.statistics }.to output(/Most frequent `place`: home/).to_stdout }
      end

      describe "adjective statistics" do
        it { expect { subject.statistics }.to output(/Most frequent `adjective`: red/).to_stdout }
      end

      describe "noun statistics" do
        it { expect { subject.statistics }.to output(/Most frequent `noun`: coin/).to_stdout }
      end
    end
  end
end
