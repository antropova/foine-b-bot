# frozen_string_literal: true

require 'open-uri'
require 'httparty'

class Horoscope
  attr_accessor :name, :sign, :zodiac_emoji

  BROADLY_RSS = 'https://broadly.vice.com/en_us/rss'
  ZODIAC_EMOJI = {
    cancer: '♋️',
    virgo: '♍️',
    gemini: '♊️',
    capricorn: '♑️',
  }.freeze

  def initialize(name:, sign:)
    @name = name
    @sign = sign
    @zodiac_emoji = ZODIAC_EMOJI[sign.downcase.to_sym]
  end

  def parse_horoscope
    parsed_object = {}

    feed = RSS::Parser.parse(response.body)
    parsed_object[:channel_title] = "✨ Your daily horoscope from #{feed.channel.title} for #{name} ✨\n"
    parsed_object[:horoscope] = feed.items.first.content_encoded.match(sign_regex)[1]

    "#{parsed_object[:channel_title]} #{zodiac_emoji} #{format_horoscope(parsed_object[:horoscope]) }#{zodiac_emoji}"
  rescue => exception
    Raven.capture_exception(exception)
  end

  private

  def sign_regex
    %r{#{sign}<\/a>(.*?)<\/p>}
  end

  def response
    HTTParty.get(BROADLY_RSS)
  end

  def format_horoscope(matching_string)
    return if matching_string.empty?

    matching_string.split('<p>').last.split('</p>').last
  end
end
