require "story"

RSpec.describe Story do
  describe "#story" do
    let(:json) { "" }
    let(:story) { "One day Anna was walking her 2 mile commute to school and found a blue rock on the ground.\n" }

    subject { Story.new.story(json) }

    it "outputs a predefined story" do
      expect { subject }.to output(story).to_stdout
    end
  end
end
