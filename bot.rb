# frozen_string_literal: true

require 'bundler'
Bundler.require

require_relative 'horoscope'

class TelegramBot
  attr_reader :user

  DB = Sequel.connect(ENV['DATABASE_URL'])

  def initialize(user:)
    @user = user
  end

  def horoscope
    Horoscope.new(name: user[:name], sign: user[:zodiac])
  end

  def send_message
    if user[:name] == 'Masha'
      Telegram::Bot::Client.run(ENV['TELEGRAM_TOKEN']) do |bot|
        bot.api.send_message(
          chat_id: user[:telegram_id],
          text: horoscope.parse_horoscope
        )
      end
    end
  end
end

users = TelegramBot::DB[:users]
users.each do |user|
  telegram_bot = TelegramBot.new(user: user)
  telegram_bot.send_message
end

# bot = Telegram::Bot::Client.new(ENV['TELEGRAM_TOKEN'])
# puts ENV['TELEGRAM_TOKEN']
# puts 'hi'
# bot.listen do |message|
#   puts message.chat.id
#   puts message
#   case message.text
#   when 'hey'
#     puts "#{message.chat.id}"
#     puts 'this is hey'
#     # bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
#   end
# end
