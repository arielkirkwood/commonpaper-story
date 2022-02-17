require "story"

RSpec.describe Story do
  describe "#story" do
    let(:expected_story) { "One day Anna was walking her 2 mile commute to school and found a blue rock on the ground.\n" }

    subject { Story.new.story }

    it "outputs the expected story to stdout" do
      expect { subject }.to output(expected_story).to_stdout
    end
  end
end
