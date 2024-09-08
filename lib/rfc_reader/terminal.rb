# frozen_string_literal: true

module RfcReader
  module Terminal
    # @param content [String]
    def self.page(content)
      require "tty-pager"
      TTY::Pager.page(content)
    end

    # @param prompt [String]
    # @param choices [Array<String>] where all choices are unique
    def self.choose(prompt, choices)
      require "tty-prompt"
      TTY::Prompt.new.select(prompt, choices)
    rescue TTY::Reader::InputInterrupt
      exit # We want people to be able to control-C out of this prompt.
    end
  end
end
