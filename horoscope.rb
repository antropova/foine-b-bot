# frozen_string_literal: true

require 'open-uri'
require 'httparty'

class Horoscope
  attr_accessor :name, :sign, :zodiac_emoji

  ZODIAC_EMOJI = {
    aries: '♈️',
    taurus: '♉️',
    gemini: '♊️',
    cancer: '♋️',
    leo: '♌️',
    virgo: '♍️',
    libra: '♎️',
    scorpio: '♏️',
    sagittarius: '♐️',
    capricorn: '♑️',
    aquarius: '♒️',
    pisces: '♓️',
  }.freeze

  def initialize(name:, sign:)
    @name = name
    @sign = sign
    @zodiac_emoji = ZODIAC_EMOJI[sign.downcase.to_sym]
  end

  def parse_horoscope
    parsed_object = {}
    retries ||= 0

    feed = RSS::Parser.parse(response.body)
    parsed_object[:channel_title] = "✨ Your daily horoscope from #{feed.channel.title} for #{name} ✨\n"
    parsed_object[:horoscope] = feed.items.first.content_encoded.match(sign_regex)[1]

    "#{parsed_object[:channel_title]} #{zodiac_emoji} #{format_horoscope(parsed_object[:horoscope])} #{zodiac_emoji}"
  rescue NoMethodError => exception
    retries += 1

    Raven.extra_context retries: retries
    Raven.capture_exception(exception)

    retry if retries <= ENV['RSS_PARSE_RETRIES'].to_i
  end

  private

  def sign_regex
    %r{#{sign}<\/a>(.*?)<\/p>}
  end

  def parse_link_regex
    %r{<a href="(.*?)" target="_blank">here<\/a>}
  end

  def parsed_link(horoscope_text)
    horoscope_text.match(parse_link_regex)[1]
  end

  def response
    HTTParty.get(ENV['VICE_HOROSCOPE_RSS'])
  end

  def parse_horoscope_link(horoscope_text)
    horoscope_text.gsub(parse_link_regex, "here -- #{parsed_link(horoscope_text)}")
  end

  def format_horoscope(matching_string)
    return if matching_string.empty?

    horoscope_text = matching_string.split('<p>').last.split('</p>').last

    horoscope_text.match?(parse_link_regex) ? parse_horoscope_link(horoscope_text) : horoscope_text
  end
end
