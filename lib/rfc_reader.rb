# frozen_string_literal: true

require_relative "rfc_reader/version"

module RfcReader
  autoload :Command, "rfc_reader/command"
  autoload :Recent, "rfc_reader/recent"
  autoload :Search, "rfc_reader/search"
  autoload :Library, "rfc_reader/library"
end
