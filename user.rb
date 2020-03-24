# frozen_string_literal: true

require "bundler"
Bundler.require

require_relative "horoscope"

DB = Sequel.connect(ENV["DATABASE_URL"])

class User < Sequel::Model(:users)
  attr_reader :user

  def initialize(user:)
    @user = user
  end

  def horoscope
    Horoscope.new(name: user[:name], sign: user[:zodiac])
  end

  def send_message
    Telegram::Bot::Client.run(ENV["TELEGRAM_TOKEN"]) do |bot|
      bot.api.send_message(
        chat_id: user[:telegram_id],
        text: horoscope.generate_horoscope
      )
    end
  rescue => e
    Raven.capture_exception(e)
  end

  def self.db
    DB
  end
end
