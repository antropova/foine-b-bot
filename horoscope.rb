# frozen_string_literal: true

require 'open-uri'
require 'httparty'
require 'pry'

require_relative 'no_matches_error'

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
    @horoscope_url = full_horoscope_url
  end

  def generate_horoscope
    retries ||= 0

    body = HTTParty.get(horoscope_url).body
    nokogiri_body = Nokogiri::HTML(body)

    parse_text(nokogiri_body, retries)
  end

  private

  def full_horoscope_url
    "#{ENV['HOROSCOPE_URL']}/#{sign}/daily/#{Date.today.strftime('%Y-%m-%d')}"
  end

  def sign_regex
    %r{(#{sign.downcase}\.jpeg" .*?)<p>(.*?)<\/p>}
  end

  def parse_text(body, retries)
    today_text = body.css('.astroguide-sign-content__body').text
    cosmic_event_title = body.css('.astroguide-cosmic-event > h2').text
    cosmic_event_text = body.css('.astroguide-cosmic-event__article > p:first-child').text

    raise NoMatchesError if today_text.empty?

    parsed_text = "#{today_text}\n#{cosmic_event_title}\n#{cosmic_event_text}"

    channel_title = "✨ Daily horoscope from Vice for #{name.capitalize} ✨\n"
    horoscope_text = "#{zodiac_emoji} #{parsed_text} #{zodiac_emoji}"

    "#{channel_title}\n#{horoscope_text}"
  rescue NoMatchesError => e
    retries += 1

    Raven.extra_context retries: retries
    Raven.capture_exception(e)

    retry if retries <= ENV["RSS_PARSE_RETRIES"].to_i
  end

  def parse_link_regex
    %r{<a href="(.*?)" target="_blank">here<\/a>}
  end

  def parsed_link(horoscope_text)
    horoscope_text.match(parse_link_regex)[1]
  end

  def parse_horoscope_link(horoscope_text)
    horoscope_text.gsub(parse_link_regex, "here -- #{parsed_link(horoscope_text)}")
  end

  def format_horoscope(matching_string)
    matching_string.match?(parse_link_regex) ? parse_horoscope_link(matching_string) : matching_string
  end
end
