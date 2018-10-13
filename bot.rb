require 'telegram/bot'

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.api.send_message(
    chat_id: linda_chat_id,
    text: "morning to the baddest bitch in the worldddddd 😻"
  )
  # bot.api.send_message(
  #   chat_id: masha_chat_id,
  #   text: "hey girl"
  # )
  bot.api.send_message(
    chat_id: quinn_chat_id,
    text: "drink yo coffee, bro"
  )
end

# bot = Telegram::Bot::Client.new(TOKEN)

# bot.listen do |message|
#   case message.text.downcase
#   when 'hey'
#     puts "#{message.chat.id}"
#     bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
#   else
#     puts "#{message.chat.id}"
#     bot.api.send_message(chat_id: message.chat.id, text: "you suck, #{message.from.first_name.downcase}")
#   end
# end
