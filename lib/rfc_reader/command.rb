# frozen_string_literal: true

require "thor"

module RfcReader
  class Command < Thor
    def self.exit_on_failure? = true

    def help(command = nil)
      unless command
        puts <<~DESCRIPTION
          >>> rfc-reader

          This command downloads the plaintext version of RFCs from
          rfc-editor.org so that they can be read at the command line.

          The most recent 15 RFCs are saved locally so that they can be
          read later on without the need for an internet connection.

        DESCRIPTION
      end

      super
    end

    desc "search [TERM]", "Search for RFCs by TERM for reading"
    long_desc <<-LONGDESC
      Search for RFCs on rfc-editor.org by the given term and list them.

      Choose any RFC from the list that seems interesting and
      it will get downloaded so that you can read it in your terminal.
    LONGDESC
    def search(term)
      search_results = Search.search_by(term: term)
      title = Terminal.choose("Choose an RFC to read:", search_results.keys)
      url = search_results.fetch(title)
      content = Library.download_document(title: title, url: url)
      Terminal.page(content)
    end

    desc "recent", "List recent RFC releases for reading"
    long_desc <<-LONGDESC
      Fetch the most recent 15 RFCs on rfc-editor.org and list them.

      Choose any RFC from the list that seems interesting and
      it will get downloaded so that you can read it in your terminal.
    LONGDESC
    def recent
      recent_results = Recent.list
      title = Terminal.choose("Choose an RFC to read:", recent_results.keys)
      url = recent_results.fetch(title)
      content = Library.download_document(title: title, url: url)
      Terminal.page(content)
    end

    desc "library", "List already downloaded RFCs for reading"
    long_desc <<-LONGDESC
      List the last 100 RFCs that have already been downloaded.

      Choose any RFC from the list that seems interesting and
      you can read it offline in your terminal.
    LONGDESC
    def library
      rfc_catalog = Library.catalog
      all_titles = rfc_catalog.map { _1[:title] }
      title = Terminal.choose("Choose an RFC to read:", all_titles)
      rfc = rfc_catalog.find { _1[:title] == title }
      content = Library.load_document(**rfc)
      Terminal.page(content)
    end

    desc "version", "Print the program version"
    def version
      puts VERSION
    end
  end
end
