# frozen_string_literal: true

# lib/tasks/db.rake

require "rake"
require "active_record"
require "yaml"
require "mysql2"

namespace :db do
  def load_config
    YAML.load_file("config/database.yml")["test"]
  end

  def create_database(config, database)
    charset = config["encoding"] || "utf8mb4"
    collation = config["collation"] || "utf8mb4_unicode_ci"
    client = Mysql2::Client.new(
      host: config["host"],
      username: config["username"],
      password: config["password"]
    )
    client.query("CREATE DATABASE IF NOT EXISTS `#{database}` CHARACTER SET #{charset} COLLATE #{collation}")
    client.close
  end

  desc "Create test databases"
  task :create do
    config = load_config
    %w[default customer_analytics].each do |db|
      create_database(config[db], config[db]["database"])
      puts "Created database '#{config[db]["database"]}'"
    end
  end

  desc "Drop test databases"
  task :drop do
    config = load_config
    %w[default customer_analytics].each do |db|
      client = Mysql2::Client.new(
        host: config[db]["host"],
        username: config[db]["username"],
        password: config[db]["password"]
      )
      client.query("DROP DATABASE IF EXISTS `#{config[db]["database"]}`")
      client.close
      puts "Dropped database '#{config[db]["database"]}'"
    end
  end

  desc "Run migrations for test databases"
  task migrate: :create do
    config = load_config

    # Migrate default database
    ActiveRecord::Base.establish_connection(config["default"])
    require_relative "../../db/migrate/create_test_tables"
    CreateTestTables.new.up
    puts "Migrated default database"

    # Migrate customer_analytics database
    ActiveRecord::Base.establish_connection(config["customer_analytics"])
    CreateTestTables.new.up
    puts "Migrated customer_analytics database"

    puts "Migration completed successfully."
  end

  desc "Rollback migrations for test databases"
  task :rollback do
    config = load_config

    # Rollback default database
    ActiveRecord::Base.establish_connection(config["default"])
    require_relative "../../db/migrate/create_test_tables"
    CreateTestTables.new.down
    puts "Rolled back default database"

    # Rollback customer_analytics database
    ActiveRecord::Base.establish_connection(config["customer_analytics"])
    CreateTestTables.new.down
    puts "Rolled back customer_analytics database"

    puts "Rollback completed successfully."
  end
end
