# frozen_string_literal: true

require 'bundler'
Bundler.require

require_relative 'user'

DB = User.db
users = DB[:users]
users.each do |user|
  telegram_bot = User.new(user: user)
  telegram_bot.send_message
end
