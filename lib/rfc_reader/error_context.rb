# frozen_string_literal: true

require "forwardable"

module RfcReader
  module ErrorContext
    class ContextError < StandardError
      extend Forwardable

      attr_reader :context

      def_delegators :@cause, :message, :to_s, :backtrace, :backtrace_locations

      # @param cause [StandardError]
      # @param context [String] (Optional)
      def initialize(cause:, context: default_context)
        @cause = cause
        @context = context
        super
      end

      def short_message
        "Error: #{context}"
      end

      def full_message
        <<~MESSAGE
          Context: #{context}
          Error: #{cause.class}
          Message:
          #{message}
          Backtrace:
          #{bracktrace}
        MESSAGE
      end

      private

      def default_context
        "#{cause.class}: #{message.lines.first}"
      end
    end

    # Yields an error context. Any `StandardError` that gets raised in this block
    # gets wrapped by `ContextError` automatically and re-raised.
    #
    # If no error has been raised, it returns the result of the block.
    #
    # @param context [String]
    # @return yielded block value
    def self.wrap(context)
      yield
    rescue StandardError => e
      raise ContextError.new(cause: e, context: context)
    end

    # Yields a handler context where any `StandardError` is caught and the error message is
    # printed to stderr along with the context. It prints only a short message by default
    # and prints the full error message if the `DEBUG` error message is set. It then exits
    # with a non-zero error code.
    #
    # If no error has been raised, it returns the result of the block as an integer.
    # If the result of block cannot be turned into an integer, it returns zero.
    #
    # @return [Integer] exit code
    def self.handler
      error = nil

      begin
        result = yield
        return result.respond_to?(:to_i) ? result.to_i : 0
      rescue ContextError => e
        error = e
      rescue StandardError => e
        error = ContextError.new(cause: e)
      end

      if ENV["DEBUG"]
        warn error.full_message
      else
        warn error.short_message
        warn "Note: Set the `DEBUG` environment variable to see the full error context"
      end

      1
    end
  end
end
