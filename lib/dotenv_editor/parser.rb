# frozen_string_literal: true

module DotenvEditor
  # Takes a dotenv file, and parses it.
  # We can't reuse the dotenv gem's parser because we don't want to resolve
  # variables or do any interpolation.
  class Parser
    def self.call(io)
      new(io).call
    end

    def initialize(io)
      @raw = io.read
    end

    # Lifted from dotenv gem
    LINE = /
      (?:^|\A)              # beginning of line
      \s*                   # leading whitespace
      (?:export\s+)?        # optional export
      ([\w.]+)             # key
      (?:\s*=\s*?|:\s+?)    # separator
      (                     # optional value begin
        \s*'(?:\\'|[^'])*'  #   single quoted value
        |                   #   or
        \s*"(?:\\"|[^"])*"  #   double quoted value
        |                   #   or
        [^\#\r\n]+          #   unquoted value
      )?                    # value end
      \s*                   # trailing whitespace
      (?:\#.*)?             # optional comment
      (?:$|\z)              # end of line
    /x

    def call
      # We'll update this as we parse
      result = ParsedDotenv.new

      # Convert line breaks to same format
      lines = @raw.gsub(/\r\n?/, "\n")

      lines.scan(LINE).each do |key, value|
        result.add(key, value)
      end

      result
    end
  end
end
