# frozen_string_literal: true

require "spec_helper"

RSpec.describe RfcReader::ErrorContext do
  describe ".wrap" do
    context "with error" do
      let(:test_error) { StandardError.new("Testing .wrap") }

      it "wraps the error and re-raises it" do
        error = nil

        begin
          described_class.wrap("Testing error context wrapper") do
            raise test_error
          end
        rescue described_class::ContextError => e
          error = e
        end

        expect(error).to have_attributes(
          context: "Testing error context wrapper",
          cause: test_error,
          message: test_error.message,
          to_s: test_error.to_s,
          backtrace: test_error.backtrace,
          backtrace_locations: test_error.backtrace_locations
        )
      end
    end

    context "without error" do
      it "returns yielded value", :aggregate_failures do
        [42, "fourty-two", nil, [4, 2]].each do |value|
          expect(described_class.wrap("test") { value }).to eq(value)
        end
      end
    end
  end

  describe ".handler" do
    context "with error and DEBUG" do
      before do
        allow(ENV).to receive(:[]).with("DEBUG").and_return("1")
      end

      it "handles custom error and returns non-zero exit code", :aggregate_failures do
        exit_code = nil
        short_message = <<~MESSAGE
          Context:
             ArgumentError: Unexpected date argument...
          Error:
             ArgumentError
          Message:
             Unexpected date argument...
          Backtrace:
        MESSAGE

        expect do
          exit_code = described_class.handler do
            raise ArgumentError, "Unexpected date argument..."
          end
        end.to output(start_with(short_message)).to_stderr
          .and not_output.to_stdout

        expect(exit_code).to eq(1)
      end

      it "handles context error and returns non-zero exit code", :aggregate_failures do
        exit_code = nil
        short_message = <<~MESSAGE
          Context:
             Parsing date argument
          Error:
             ArgumentError
          Message:
             Unexpected date argument...
          Backtrace:
        MESSAGE

        expect do
          exit_code = described_class.handler do
            described_class.wrap("Parsing date argument") do
              raise ArgumentError, "Unexpected date argument..."
            end
          end
        end.to output(start_with(short_message)).to_stderr
          .and not_output.to_stdout

        expect(exit_code).to eq(1)
      end
    end

    context "with error and without DEBUG" do
      before do
        allow(ENV).to receive(:[]).with("DEBUG").and_return(nil)
      end

      it "handles custom error and returns non-zero exit code", :aggregate_failures do
        exit_code = nil
        short_message = <<~MESSAGE
          Error: ArgumentError: Unexpected date argument...
          Note: Set the `DEBUG` environment variable to see the full error context
        MESSAGE

        expect do
          exit_code = described_class.handler do
            raise ArgumentError, "Unexpected date argument..."
          end
        end.to output(short_message).to_stderr
          .and not_output.to_stdout

        expect(exit_code).to eq(1)
      end

      it "handles context error and returns non-zero exit code", :aggregate_failures do
        exit_code = nil
        short_message = <<~MESSAGE
          Error: Parsing date argument
          Note: Set the `DEBUG` environment variable to see the full error context
        MESSAGE

        expect do
          exit_code = described_class.handler do
            described_class.wrap("Parsing date argument") do
              raise ArgumentError, "Unexpected date argument..."
            end
          end
        end.to output(short_message).to_stderr
          .and not_output.to_stdout

        expect(exit_code).to eq(1)
      end
    end

    context "without error", :aggregate_failures do
      it "succeed and returns default exit code" do
        exit_code = nil

        expect do
          exit_code = described_class.handler do
            { one: 1, two: 2 }
          end
        end.to not_output.to_stdout
          .and not_output.to_stderr

        expect(exit_code).to eq(0)
      end

      it "succeed and returns converted exit code" do
        exit_code = nil

        expect do
          exit_code = described_class.handler do
            nil
          end
        end.to not_output.to_stdout
          .and not_output.to_stderr

        expect(exit_code).to eq(0)
      end

      it "succeed and returns custom exit code" do
        exit_code = nil

        expect do
          exit_code = described_class.handler do
            5 + 6
          end
        end.to not_output.to_stdout
          .and not_output.to_stderr

        expect(exit_code).to eq(11)
      end
    end
  end
end
