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
      TTY::Prompt
        .new(
          quiet: true,
          track_history: false,
          interrupt: :exit,
          symbols: { marker: ">" },
          enable_color: !ENV["NO_COLOR"]
        )
        .select(prompt, choices)
    end
  end
end
