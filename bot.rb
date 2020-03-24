# frozen_string_literal: true

require 'bundler'
Bundler.require

require_relative 'user'

USER_DB = User.db
users = USER_DB[:users]

users.where(paused: false).each do |user|
  telegram_bot = User.new(user: user)
  telegram_bot.send_message
end
