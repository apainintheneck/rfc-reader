# frozen_string_literal: true

module RfcReader
  module Terminal
    def self.page(content)
      require "tty-pager"
      TTY::Pager.page(content)
    end

    def self.choose(prompt, choices)
      require "tty-prompt"
      TTY::Prompt.new.select(prompt, choices)
    rescue TTY::Reader::InputInterrupt
      exit # We want people to be able to control-C out of this prompt.
    end
  end
end
