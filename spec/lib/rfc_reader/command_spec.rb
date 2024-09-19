# frozen_string_literal: true

RSpec.describe RfcReader::Command do
  describe "help" do
    it "matches default command usage" do
      expect { described_class.start }
        .to output(snapshot("command-help")).to_stdout
        .and not_to_output.to_stderr
    end

    it "matches default command help" do
      expect { described_class.start(%w[help]) }
        .to output(snapshot("command-help")).to_stdout
        .and not_to_output.to_stderr
    end

    it "matches command specific help pages", :aggregate_failures do
      %w[library recent search].each do |subcommand|
        expect { described_class.start(["help", subcommand]) }
          .to output(snapshot("command-help-#{subcommand}")).to_stdout
          .and not_to_output.to_stderr
      end
    end
  end
end
