require "rails_helper"
RSpec.describe DiffbotService do
  describe ".fetch" do
    context "valid params" do
      it "returns a correctly structured hash", :vcr do
        result = described_class.fetch("https://www.farnamstreetblog.com/2014/02/quotable-kierkegaard/")
        expect(result[:slyp_type]).to eq "article"
        expect(result[:title]).to eq "26 Musings from Kierkegaard"
      end
    end
  end
end