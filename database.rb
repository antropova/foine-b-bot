require 'bundler'
Bundler.require

DB = Sequel.connect(ENV['DATABASE_URL'])

DB.create_table :users do
  primary_key :id
  String :name
  String :zodiac
  String :telegram_id
end
