# frozen_string_literal: true

RSpec.describe RfcReader::Command do
  describe "#recent", :setup_xdg_dirs do
    let(:title) { "RFC 9605: Secure Frame (SFrame): Lightweight Authenticated Encryption for Real-Time Media" }

    before do
      allow(RfcReader::Terminal)
        .to receive(:choose)
        .with("Choose an RFC to read:", array_including(title))
        .and_return(title)
    end

    it "downloads recent RFCs and shows the chosen one", :aggregate_failures do
      VCR.use_cassette("command-recent") do
        expect { described_class.start(%w[recent]) }
          .to output(snapshot("rfc-9605")).to_stdout
      end

      catalog = RfcReader::Library.catalog

      expect(catalog).to match([
        {
          path: end_with("library/rfc9605.txt"),
          title: title,
          url: "https://www.rfc-editor.org/rfc/rfc9605.txt",
        },
      ])

      expect(RfcReader::Library.load_document(**catalog.first))
        .to match_snapshot("rfc-9605")
    end
  end

  describe "#search", :setup_xdg_dirs do
    let(:title) { "Common Format and MIME Type for Comma-Separated Values (CSV) Files" }

    before do
      allow(RfcReader::Terminal)
        .to receive(:choose)
        .with("Choose an RFC to read:", array_including(title))
        .and_return(title)
    end

    it "searches RFCs and shows the chosen one", :aggregate_failures do
      VCR.use_cassette("command-search-for-csv") do
        expect { described_class.start(%w[search csv]) }
          .to output(snapshot("rfc-4180")).to_stdout
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

    before do
      allow(RfcReader::Terminal)
        .to receive(:choose)
        .with("Choose an RFC to read:", array_including(title))
        .and_return(title)

      FileUtils.mkdir_p(RfcReader::Library.library_cache_dir)
      File.write(RfcReader::Library.library_cache_list_path, JSON.pretty_generate(library_list))
      FileUtils.cp(fixture("rfc4180.txt"), path)
    end

    it "lists downloaded RFCs and shows the chosen one" do
      expect { described_class.start(%w[library]) }
        .to output(snapshot("rfc-4180")).to_stdout
    end
  end
end
