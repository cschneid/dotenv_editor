# frozen_string_literal: true

RSpec.describe DotenvEditor::Dotenv do
  let(:basic_testcase) { fixture("basic") }

  it "can round-trip a file without editing it" do
    expect(DotenvEditor::Dotenv.new(basic_testcase).to_env).to eq basic_testcase
  end

  describe "#value" do
    it "can extact the current value of a key (including wrapping quotes)" do
      expect(DotenvEditor::Dotenv.new(basic_testcase).value("A")).to eq "b"
      expect(DotenvEditor::Dotenv.new(basic_testcase).value("C")).to eq "dddd"
      expect(DotenvEditor::Dotenv.new(basic_testcase).value("E")).to eq "f\ng" # real \n
      expect(DotenvEditor::Dotenv.new(basic_testcase).value("SPACED")).to eq "a b c d e"
    end

    it "Trims trailing whitespace of the value" do
      expect(DotenvEditor::Dotenv.new(basic_testcase).value("TRAILING_WHITESPACE")).to eq "a   b"
    end

    it "can read lowercased keys" do
      # Lowercase Key
      expect(DotenvEditor::Dotenv.new(basic_testcase).value("lowerkey")).to eq "is lowercase"
    end

    it "returns nil if the key doesn't exist" do
      expect(DotenvEditor::Dotenv.new(basic_testcase).value("NOTHING_HERE")).to be_nil
    end

    it "reflects just-set values" do
      val = DotenvEditor::Dotenv.new(basic_testcase)
        .set("C", "xxxx")
        .value("C")
      expect(val).to eq("xxxx")
    end
  end

  describe "#set" do
    it "a value for an existing key" do
      edited = DotenvEditor::Dotenv.new(basic_testcase).set("C", "xxxx").to_env
      expect(edited).to include("C=xxxx")
    end

    it "preserves spacing and comments" do
      edited = DotenvEditor::Dotenv.new(basic_testcase).set("TRAILING_COMMENT", "zz").to_env
      expect(edited).to include("TRAILING_COMMENT =zz # this is important")
    end

    it "handles a brand new key by appending" do
      edited = DotenvEditor::Dotenv.new(basic_testcase).set("NEW_KEY", "brand new").to_env
      expect(edited).to include("NEW_KEY=brand new")
    end
  end

  def fixture(name)
    File.read(File.dirname(__FILE__) + "/fixtures/#{name}.env")
  end
end
