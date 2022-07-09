# frozen_string_literal: true

RSpec.describe DotenvEditor::Parser do
  it "creates a parsed dotenv" do
    expect(DotenvEditor::Parser.call(basic_testcase)).to be_a DotenvEditor::ParsedDotenv
  end

  it "creates a parsed dotenv with values filled in" do
    parsed = DotenvEditor::Parser.call(basic_testcase)
    expect(parsed.to_h).to eq({
      "A" => "b",
      "C" => %("dddd"),
      "E" => %("f\\ng")
    })
  end

  def basic_testcase
    StringIO.new(<<-TESTCASE)
      A=b
      C="dddd" # Trailing Comment

      # Comment
      E="f\\ng"
      
    TESTCASE
  end
end
