# frozen_string_literal: true

require "open-uri"
require "httparty"

require_relative "no_matches_error"

class Horoscope
  attr_accessor :name, :sign, :zodiac_emoji

  ZODIAC_EMOJI = {
    aries: "♈️",
    taurus: "♉️",
    gemini: "♊️",
    cancer: "♋️",
    leo: "♌️",
    virgo: "♍️",
    libra: "♎️",
    scorpio: "♏️",
    sagittarius: "♐️",
    capricorn: "♑️",
    aquarius: "♒️",
    pisces: "♓️",
  }.freeze

  def initialize(name:, sign:)
    @name = name
    @sign = sign.downcase
    @zodiac_emoji = ZODIAC_EMOJI[sign.downcase.to_sym]
  end

  def parse_horoscope
    retries ||= 0

    feed = RSS::Parser.parse(response.body)
    horoscope_matches = feed.items.first.content_encoded.match(sign_regex)

    raise NoMatchesError unless horoscope_matches

    channel_title = "✨ #{name.capitalize}\'s daily horoscope from #{feed.channel.title} ✨\n"
    horoscope_text = "#{zodiac_emoji} #{format_horoscope(horoscope_matches[2])} #{zodiac_emoji}"

    "#{channel_title} #{horoscope_text}"
  rescue NoMatchesError => exception
    retries += 1

    Raven.extra_context retries: retries
    Raven.capture_exception(exception)

    retry if retries <= ENV["RSS_PARSE_RETRIES"].to_i
  end

  private

  def sign_regex
    %r{(#{sign.downcase}\.jpeg" .*?)<p>(.*?)<\/p>}
  end

  def parse_link_regex
    %r{<a href="(.*?)" target="_blank">here<\/a>}
  end

  def parsed_link(horoscope_text)
    horoscope_text.match(parse_link_regex)[1]
  end

  def response
    HTTParty.get(ENV["VICE_HOROSCOPE_RSS"])
  end

  def parse_horoscope_link(horoscope_text)
    horoscope_text.gsub(parse_link_regex, "here -- #{parsed_link(horoscope_text)}")
  end

  def format_horoscope(matching_string)
    matching_string.match?(parse_link_regex) ? parse_horoscope_link(matching_string) : matching_string
  end
end
