# frozen_string_literal: true

require "bundler"
Bundler.require

require_relative "user"

DB = User.db
users = DB[:users]
users.where(admin: true).each do |user|
  telegram_bot = User.new(user: user)
  telegram_bot.send_message
end
