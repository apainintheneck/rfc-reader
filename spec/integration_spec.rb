# frozen_string_literal: true

require "spec_helper"

RSpec.describe "integration tests" do
  let(:exe_path) do
    path = File.join(__dir__, "..", "exe/rfc-reader")
    File.expand_path(path)
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
