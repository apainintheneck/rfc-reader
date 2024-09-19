# frozen_string_literal: true

require "spec_helper"

RSpec.describe RfcReader do
  describe "::VERSION" do
    it "has a valid version" do
      expect(described_class::VERSION).not_to be_nil
    end
  end
end
