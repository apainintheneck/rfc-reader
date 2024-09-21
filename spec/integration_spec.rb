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
        expect(output.read)
          .to include("Request for Comments:")
          .and include("Status of This Memo")
          .and include("Copyright Notice")
          .and include("Table of Contents")
          .and include("1.  Introduction")
      end
    end
  end

  describe "help" do
    it "returns the default help page", :aggregate_failures do
      Open3.popen2(exe_path) do |_input, output|
        expect(output.read).to match_snapshot("command-help")
      end
      Open3.popen2(exe_path, "help") do |_input, output|
        expect(output.read).to match_snapshot("command-help")
      end
    end

    it "shows the subcommand help page", :aggregate_failures do
      Open3.popen2(exe_path, "help", "recent") do |_input, output|
        expect(output.read).to match_snapshot("command-help-recent")
      end
      Open3.popen2(exe_path, "help", "library") do |_input, output|
        expect(output.read).to match_snapshot("command-help-library")
      end
      Open3.popen2(exe_path, "help", "search") do |_input, output|
        expect(output.read).to match_snapshot("command-help-search")
      end
    end
  end
end
