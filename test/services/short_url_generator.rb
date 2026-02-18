require "test_helper"

class ShortUrlGeneratorTest < ActiveSupport::TestCase
  test "generates code with default length of 6" do
    code = ShortUrlGenerator.generate

    assert_equal 6, code.length
  end

  test "generates code with custom length" do
    code = ShortUrlGenerator.generate(length: 10)

    assert_equal 10, code.length
  end

  test "generates code with minimum length of 1" do
    code = ShortUrlGenerator.generate(length: 1)

    assert_equal 1, code.length
  end

  test "generates code with only alphanumeric characters" do
    100.times do
      code = ShortUrlGenerator.generate
      assert_match /^[a-zA-Z0-9]+$/, code, "Code contains non-alphanumeric: #{code}"
    end
  end

  test "generates different codes on each call" do
    codes = 100.times.map { ShortUrlGenerator.generate }

    assert codes.uniq.length >= 95, "Too many duplicate codes generated"
  end

  test "uses correct character set" do
    codes = 1000.times.map { ShortUrlGenerator.generate }
    all_chars = codes.join.chars.uniq.sort

    expected_chars = (("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a).sort

    all_chars.each do |char|
      assert_includes expected_chars, char, "Unexpected character: #{char}"
    end
  end

  test "generates codes with mixed case" do
    codes = 100.times.map { ShortUrlGenerator.generate }
    all_chars = codes.join.chars

    has_lowercase = all_chars.any? { |c| c =~ /[a-z]/ }
    has_uppercase = all_chars.any? { |c| c =~ /[A-Z]/ }
    has_digits = all_chars.any? { |c| c =~ /[0-9]/ }

    assert has_lowercase, "No lowercase letters generated"
    assert has_uppercase, "No uppercase letters generated"
    assert has_digits, "No digits generated"
  end

  test "generates valid codes for URL usage" do
    code = ShortUrlGenerator.generate

    assert code !~ /[^a-zA-Z0-9]/, "Code contains URL-unsafe characters"
  end
end
