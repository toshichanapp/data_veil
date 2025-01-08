# frozen_string_literal: true

require_relative "data_veil/version"
require "erb"
require "faker"
require "thor"
require "uri"
require "yaml"
begin
  require "dotenv/load"
rescue LoadError
end
require "active_record"
require "data_veil/mask_data_generator"
require "data_veil/masking/initializer"
require "data_veil/mask/base"
require "data_veil/cli"

module DataVeil
  class Error < StandardError; end
  # Your code goes here...
end
