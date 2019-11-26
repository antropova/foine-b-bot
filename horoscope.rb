# frozen_string_literal: true

require "open-uri"
require "httparty"

require_relative "no_matches_error"

class Horoscope
  attr_accessor :name, :sign, :zodiac_emoji, :horoscope_url

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
    @horoscope_url = "https://www.vice.com/en_us/astroguide/#{sign}/daily/#{Date.today.strftime('%Y-%m-%d')}"
  end

  def parse_horoscope
    retries ||= 0

    body = HTTParty.get(horoscope_url).body
    nokogiri_body = Nokogiri::HTML(body)
    parsed_text = nokogiri_body.css('.astroguide-sign-content__body').text

    raise NoMatchesError if parsed_text.empty?

    channel_title = "✨ #{name.capitalize}\'s daily horoscope from Vice ✨\n"
    horoscope_text = "#{zodiac_emoji} #{parsed_text} #{zodiac_emoji}"

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
