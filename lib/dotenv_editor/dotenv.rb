# Holds onto an opened Dotenv file, and provides mechanisms
# to seek, search, edit and output
module DotenvEditor
  class Dotenv
    # Borrowed & Edited from dotenv gem
    LINE = /
      ^                       # beginning of line
      \s*                     # leading whitespace
      (?<export>export\s+)?   # optional export
      (?<key>[\w.]+)          # key
      (?<sep>\s*=\s*?|:\s+?)  # separator
      (?<value>               # optional value begin
        \s*'(?:\\'|[^'])*'    #   single quoted value
        |                     #   or
        \s*"(?:\\"|[^"])*"    #   double quoted value
        |                     #   or
        [^\#\r\n]+            #   unquoted value
      )?                      # value end
      (?<whitespace>\s*)      # trailing whitespace
      (?<comment>\#.*)?       # optional comment
      (?:$|\z)                # end of line
    /x

    def initialize(env_string)
      @lines = env_string.each_line.map(&:chomp)
    end

    def value(key)
      @lines.each do |line|
        if (match = line.match(LINE)) && match[:key] == key
          return parse_value(match[:value])
        end
      end

      # Nothing found
      nil
    end

    def set(key, new_val)
      found_key = false

      @lines = @lines.map do |line|
        if (match = line.match(LINE)) && match[:key] == key
          found_key = true

          # Rebuild the line w/ the new value
          old_val = match[:value]
          after_val_whitespace = old_val.match(/^.*?(\s*)$/)[1] # non greedy .* to start

          [
            match[:export],
            match[:key],
            match[:sep],
            new_val,
            after_val_whitespace,
            match[:whitespace],
            match[:comment]
          ].join
        else
          # Nothing to do on non-matching line
          line
        end
      end

      unless found_key
        @lines << "#{key}=#{new_val}"
      end

      # Return self for future chaining.
      self
    end

    def to_env
      @lines.join("\n")
    end

    ### From dotenv gem ###

    def parse_value(value)
      # Remove surrounding quotes
      value = value.strip.sub(/\A(['"])(.*)\1\z/m, '\2')
      maybe_quote = Regexp.last_match(1)
      unescape_value(value, maybe_quote)
    end

    def unescape_value(value, maybe_quote)
      if maybe_quote == '"'
        unescape_characters(expand_newlines(value))
      elsif maybe_quote.nil?
        unescape_characters(value)
      else
        value
      end
    end

    def expand_newlines(value)
      value.gsub('\n', "\n").gsub('\r', "\r")
    end

    def unescape_characters(value)
      value.gsub(/\\([^$])/, '\1')
    end
  end
end
