require 'open-uri'

class Horoscope
  attr_accessor :name, :sign, :zodiac_emoji

  BROADLY_RSS = 'https://broadly.vice.com/en_us/rss'.freeze
  ZODIAC_EMOJI = {
    cancer: '♋️',
    virgo: '♍️',
    gemini: '♊️',
  }.freeze

  def initialize(name:, sign:)
    @name = name
    @sign = sign
    @zodiac_emoji = ZODIAC_EMOJI[sign.downcase.to_sym]
  end

  def parse_horoscope
    parsed_object = {}

    open(BROADLY_RSS) do |rss|
      feed = RSS::Parser.parse(rss)
      parsed_object[:channel_title] = "✨ Your daily horoscope from #{feed.channel.title} for #{name} ✨\n"
      parsed_object[:horoscope_string] = feed.items.first.content_encoded.match(sign_regex).to_s
    end

    "#{parsed_object[:channel_title]} #{zodiac_emoji} #{format_horoscope(parsed_object[:horoscope_string]) }#{zodiac_emoji}"
  end

  private

  def sign_regex
    %r{#{sign}<\/a>(.*?)<\/p>}
  end

  def format_horoscope(matching_string)
    return if matching_string.empty?

    matching_string.split('<p>').last.split('</p>').last
  end
end
