# frozen_string_literal: true

# spec/support/create_test_tables.rb

require "active_record"

class CreateTestTables < ActiveRecord::Migration[7.2]
  def up
    # Create users table
    create_table :users do |t|
      t.string :email, null: false
      t.string :name
      t.string :password
      t.string :phone

      t.timestamps
    end

    # Create customer_analytics_emails table
    create_table :customer_analytics_emails do |t|
      t.string :email, null: false
      t.string :customer_id
      t.datetime :last_sent_at

      t.timestamps
    end
  end

  def down
    drop_table :users
    drop_table :customer_analytics_emails
  end
end
