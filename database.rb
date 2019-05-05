require 'bundler'
Bundler.require

DB = Sequel.connect(ENV['DATABASE_URL'])

DB.create_table :users do
  primary_key :id
  String :name
  String :zodiac
  String :telegram_id
end

DB.transaction do
  DB.alter_table(:users) do
    add_column :admin, "BOOLEAN", default: false
  end
  DB[:users].where(name: "Masha").first.update(admin: true)
end
