# frozen_string_literal: true

require 'open-uri'
require 'httparty'
require 'pry'

require_relative 'no_matches_error'
require_relative 'no_path_found_error'

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

  def generate_horoscope
    # retries ||= 0
    body = HTTParty.get(ENV['HOROSCOPE_URL']).body
    nokogiri_body = Nokogiri::HTML(body)

    horoscope_text(nokogiri_body)
  rescue NoPathFoundError => e
    Raven.capture_exception(e)
  rescue NoMatchesError => e
    Raven.capture_exception(e)
  end

  private

  def personal_url(main_body)
    "#{ENV['HOME_URL']}#{personal_path(main_body)}"
  end

  def personal_path(main_body)
    path = main_body.css('.vice-card').first.css('.vice-card-hed__link').first.attributes['href'].value
    raise NoPathFoundError if path.empty?

    path
  end

  def sign_index
    ZODIAC_EMOJI.keys.index(sign.to_sym) + 2
  end

  def horoscope_text(nokogiri_body)
    horoscopes_url = personal_url(nokogiri_body)
    horoscopes_body = HTTParty.get(horoscopes_url).body
    horoscopes_ng_body = Nokogiri::HTML(horoscopes_body)
    main_horoscope_text = horoscopes_ng_body.css('.abc__textblock')[sign_index].text

    raise NoMatchesError if main_horoscope_text.empty?

    format_horsocope(main_horoscope_text)
  end

  def format_horsocope(main_text)
    title = "✨ Daily horoscope from Vice for #{name.capitalize} ✨\n"
    zodiac_title = "#{zodiac_emoji} #{sign.capitalize} #{zodiac_emoji}\n"

    "#{title}\n #{zodiac_title}#{main_text.strip}"
  end

  # def parse_text(body, retries)
  #   today_text = body.css('.astroguide-sign-content__body').text
  #   cosmic_event_title = body.css('.astroguide-cosmic-event > h2').text
  #   cosmic_event_text = body.css('.astroguide-cosmic-event__article > p:first-child').text

  #   raise NoMatchesError if today_text.empty?

  #   parsed_text = "#{today_text}\n#{cosmic_event_title}\n#{cosmic_event_text}"

  #   channel_title = "✨ Daily horoscope from Vice for #{name.capitalize} ✨\n"
  #   main_horoscope_text = "#{zodiac_emoji} #{parsed_text} #{zodiac_emoji}"

  #   "#{channel_title}\n#{main_horoscope_text}"
  # rescue NoMatchesError => e
  #   retries += 1

  #   Raven.extra_context retries: retries
  #   Raven.capture_exception(e)

  #   retry if retries <= ENV["RSS_PARSE_RETRIES"].to_i
  # end
end
