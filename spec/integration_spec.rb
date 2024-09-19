# frozen_string_literal: true

require "spec_helper"

RSpec.describe "integration tests" do
  let(:exe_path) do
    path = File.join(__dir__, "..", "exe/rfc-reader")
    File.expand_path(path)
  end

  let(:enter_key) { "\uE007" }

  describe "search", :online do
    it "returns the expected result" do
      Open3.popen2(exe_path, "search", "4180") do |input, output|
        input.puts enter_key
        expect(output.read).to match_snapshot("online-search")
      end
    end
  end

  describe "recent", :online do
    it "returns the expected result" do
      Open3.popen2(exe_path, "recent") do |input, output|
        input.puts enter_key
        result = output.read

        expect(result)
          .to include("Request for Comments:")
          .and include("Status of This Memo")
          .and include("Copyright Notice")
          .and include("Table of Contents")
          .and include("1.  Introduction")
      end
    end
  end
end
