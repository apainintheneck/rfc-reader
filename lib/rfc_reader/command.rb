# frozen_string_literal: true

require "thor"

module RfcReader
  class Command < Thor
    SUCCESS = 0
    private_constant :SUCCESS

    FAILURE = 1
    private_constant :FAILURE

    # @return [Boolean]
    def self.exit_on_failure? = true

    # @param command [String, nil]
    # @return [Integer] exit code
    def help(command = nil)
      unless command
        puts <<~DESCRIPTION
          >>> rfc-reader

          This command downloads the plaintext version of RFCs from
          rfc-editor.org so that they can be read at the command line.

          The last 100 downloaded RFCs are saved locally so that they can be
          read later on without the need for an internet connection.

        DESCRIPTION
      end

      super

      SUCCESS
    end

    desc "search [TERM]", "Search for RFCs by TERM for reading"
    long_desc <<-LONGDESC
      Search for RFCs on rfc-editor.org by the given term and list them.

      Choose any RFC from the list that seems interesting and
      it will get downloaded so that you can read it in your terminal.
    LONGDESC
    # @param term [String]
    # @return [Integer] exit code
    def search(term)
      search_results = Search.search_by(term: term)
      if search_results.empty?
        warn "No search results for: #{term}"
        return FAILURE
      end
      Terminal.choose("Choose an RFC to read:", search_results.keys) do |title|
        url = search_results.fetch(title)
        content = Library.download_document(title: title, url: url)
        Terminal.page(content)
      end
      SUCCESS
    end

    desc "recent", "List recent RFC releases for reading"
    long_desc <<-LONGDESC
      Fetch the most recent 15 RFCs on rfc-editor.org and list them.

      Choose any RFC from the list that seems interesting and
      it will get downloaded so that you can read it in your terminal.
    LONGDESC
    # @return [Integer] exit code
    def recent
      recent_results = Recent.list
      if recent_results.empty?
        warn "Error: Empty recent RFC list from rfc-editor.org RSS feed"
        return FAILURE
      end
      Terminal.choose("Choose an RFC to read:", recent_results.keys) do |title|
        url = recent_results.fetch(title)
        content = Library.download_document(title: title, url: url)
        Terminal.page(content)
      end
      SUCCESS
    end

    desc "library", "List already downloaded RFCs for reading"
    long_desc <<-LONGDESC
      List the last 100 RFCs that have already been downloaded.

      Choose any RFC from the list that seems interesting and
      you can read it offline in your terminal.
    LONGDESC
    # @return [Integer] exit code
    def library
      rfc_catalog = Library.catalog
      if rfc_catalog.empty?
        warn <<~MESSAGE
          No RFCs are currently saved in the library. Try using the
          `search` or `recent` commands to download some RFCs first.
        MESSAGE
        return FAILURE
      end
      all_titles = rfc_catalog.map { _1[:title] }
      Terminal.choose("Choose an RFC to read:", all_titles) do |title|
        rfc = rfc_catalog.find { _1[:title] == title }
        content = Library.load_document(**rfc)
        Terminal.page(content)
      end
      SUCCESS
    end

    desc "version", "Print the program version"
    # @return [Integer] exit code
    def version
      puts VERSION
      SUCCESS
    end
  end
end
