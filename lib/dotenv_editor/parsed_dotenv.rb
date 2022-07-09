# Represents the result of parsing a dotenv file
# Then modifications can be made to this file before
# being spun back out as the updated file.
module DotenvEditor
  class ParsedDotenv
    def initialize
      @data = {}
    end

    def add(key, value)
      @data[key] = value
    end

    def to_h
      @data
    end
  end
end
