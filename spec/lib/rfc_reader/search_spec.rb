# frozen_string_literal: true

require "spec_helper"

RSpec.describe RfcReader::Search do
  it "returns search for RFCs by term", :aggregate_failures do
    %w[csv http 9600].each do |term|
      VCR.use_cassette("search-by-#{term}") do
        expect(described_class.search_by(term: term)).to match_snapshot("search-by-#{term}")
      end
    end
  end
end
