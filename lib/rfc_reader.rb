# frozen_string_literal: true

require_relative "rfc_reader/version"

module RfcReader
  autoload :Command, "rfc_reader/command"
  autoload :Recent, "rfc_reader/recent"
  autoload :Search, "rfc_reader/search"
  autoload :Terminal, "rfc_reader/terminal"
  autoload :Library, "rfc_reader/library"
  autoload :ErrorContext, "rfc_reader/error_context"

  # @return [Integer] exit code
  def self.start
    ErrorContext.handler do
      Command.start
    end
  end
end
