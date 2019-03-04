require 'bundler'
Bundler.require

DB = Sequel.connect(ENV['TELEGRAM_TOKEN'])

DB.create_table :users do
  primary_key :id
  String :name
  String :zodiac
  String :telegram_id
end
