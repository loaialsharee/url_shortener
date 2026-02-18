class ShortUrlGenerator
  CHARSET = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a

  def self.generate(length: 6)
    Array.new(length) { CHARSET.sample }.join
  end
end
