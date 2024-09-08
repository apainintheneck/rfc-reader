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
    end

    desc "recent", "List recent RFC releases for reading"
    long_desc <<-LONGDESC
      Fetch the most recent 10 RFCs on rfc-editor.org and list them.

      Choose any RFC from the list that seems interesting and
      it will get downloaded so that you can read it in your terminal.
    LONGDESC
    def recent
    end

    desc "library", "List already downloaded RFCs for reading"
    long_desc <<-LONGDESC
      List already downloaded RFCs.

      Choose any RFC from the list that seems interesting and
      you can read it offline in your terminal.
    LONGDESC
    def library
    end

    desc "version", "Print the program version"
    def version
      puts VERSION
    end
  end
end
