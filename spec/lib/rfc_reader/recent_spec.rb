# frozen_string_literal: true

require "spec_helper"

RSpec.describe RfcReader::Recent do
  describe ".list" do
    it "returns the list of recent RFCs" do
      VCR.use_cassette("recent-list") do
        expect(described_class.list).to match_snapshot("recent-list")
      end
    end
  end
end
