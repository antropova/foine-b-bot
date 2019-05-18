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
  User.where(name: "Masha").first.update(admin: true)
end

DB.transaction do
  DB.alter_table(:users) do
    add_column :signup_completed, "BOOLEAN", default: false
  end

  User.all.each do |user|
    user.update(signup_completed: true)
  end
end
