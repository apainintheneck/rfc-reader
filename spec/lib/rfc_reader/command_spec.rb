# frozen_string_literal: true

require "spec_helper"

RSpec.describe RfcReader::Command do
  describe "#recent", :setup_xdg_dirs do
    let(:title) { "RFC 9706: TreeDN: Tree-Based Content Delivery Network (CDN) for Live Streaming to Mass Audiences" }

    it "downloads recent RFCs and shows the chosen one", :aggregate_failures do
      allow(RfcReader::Terminal)
        .to receive(:choose)
        .with("Choose an RFC to read:", array_including(title))
        .and_yield(title)

      VCR.use_cassette("command-recent") do
        expect { described_class.start(%w[recent]) }
          .to output(snapshot("rfc-9706")).to_stdout
          .and not_output.to_stderr
      end

      catalog = RfcReader::Library.catalog

      expect(catalog).to match([
        {
          path: end_with("library/rfc9706.txt"),
          title: title,
          url: "https://www.rfc-editor.org/rfc/rfc9706.txt",
        },
      ])

      expect(RfcReader::Library.load_document(**catalog.first))
        .to match_snapshot("rfc-9706")
    end
  end

  describe "#search", :setup_xdg_dirs do
    let(:title) { "Common Format and MIME Type for Comma-Separated Values (CSV) Files" }

    it "searches RFCs and shows the chosen one", :aggregate_failures do
      allow(RfcReader::Terminal)
        .to receive(:choose)
        .with("Choose an RFC to read:", array_including(title))
        .and_yield(title)

      VCR.use_cassette("command-search-for-csv") do
        expect { described_class.start(%w[search csv]) }
          .to output(snapshot("rfc-4180")).to_stdout
          .and not_output.to_stderr
      end

      catalog = RfcReader::Library.catalog

      expect(catalog).to match([
        {
          path: end_with("library/rfc4180.txt"),
          title: title,
          url: "https://www.rfc-editor.org/rfc/rfc4180.txt",
        },
      ])

      expect(RfcReader::Library.load_document(**catalog.first))
        .to match_snapshot("rfc-4180")
    end

    it "searches RFCs and prints message about no search results", :aggregate_failures do
      VCR.use_cassette("command-search-no-results") do
        expect { described_class.start(%w[search oath2]) }
          .to output("No search results for: oath2\n").to_stderr
          .and not_output.to_stdout
      end

      expect(RfcReader::Library.catalog).to be_empty
    end
  end

  describe "#library", :setup_xdg_dirs do
    let(:title) { "Common Format and MIME Type for Comma-Separated Values (CSV) Files" }
    let(:path) { File.join(RfcReader::Library.library_cache_dir, "rfc4180.txt") }
    let(:library_list) do
      [
        {
          title: title,
          url: "https://www.rfc-editor.org/rfc/rfc4180.txt",
          path: path,
        },
      ]
    end
    let(:empty_library_message) do
      <<~MESSAGE
        No RFCs are currently saved in the library. Try using the
        `search` or `recent` commands to download some RFCs first.
      MESSAGE
    end

    it "lists downloaded RFCs and shows the chosen one" do
      allow(RfcReader::Terminal)
        .to receive(:choose)
        .with("Choose an RFC to read:", array_including(title))
        .and_yield(title)

      FileUtils.mkdir_p(RfcReader::Library.library_cache_dir)
      File.write(RfcReader::Library.library_cache_list_path, JSON.pretty_generate(library_list))
      FileUtils.cp(fixture("rfc4180.txt"), path)

      expect { described_class.start(%w[library]) }
        .to output(snapshot("rfc-4180")).to_stdout
        .and not_output.to_stderr
    end

    it "prints message when library is empty" do
      expect { described_class.start(%w[library]) }
        .to output(empty_library_message).to_stderr
        .and not_output.to_stdout
    end
  end
end
