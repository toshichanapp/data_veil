# frozen_string_literal: true

module DataVeil
  module Mask
    module Base
      extend ActiveSupport::Concern

      @skip_verify_host = false

      class_methods do
        attr_accessor :skip_verify_host

        def verify_non_production_host!
          current_host = connection_db_config.host

          if defined?(ApplicationRecord)
            app_host = ApplicationRecord.connection_db_config.host
            compare_hosts(current_host, app_host, "ApplicationRecord")
          elsif ENV["DATABASE_HOST"].present? || ENV["DATABASE_URL"].present?
            env_host = ENV["DATABASE_HOST"]
            db_url = ENV["DATABASE_URL"]

            compare_hosts(current_host, env_host, "ENV['DATABASE_HOST']") if env_host
            compare_url(current_host, db_url, "ENV['DATABASE_URL']") if db_url
          else
            raise "DATABASE_URL or DATABASE_HOST not set. "
          end
        end

        def compare_hosts(current_host, other_host, source)
          if current_host == other_host
            puts "Connected to the same host as #{source}: #{current_host}"
            raise "Connected to a production database host: #{current_host}" unless skip_verify_host

            warn "Connected to a production database host: #{current_host}"

          else
            puts "Different hosts detected: Current=#{current_host}, #{source}=#{other_host}"
          end
        end

        def compare_url(current_host, url, source)
          db_uri = URI.parse(url)
          host = db_uri.host

          compare_hosts(current_host, host, source)
        end

        def columns_to_mask
          raise NotImplementedError, "You must implement the columns_to_mask method"
        end

        def mask_all!
          verify_non_production_host!
          in_batches do |relation|
            relation.each(&:mask)
            relation.upsert_all(relation.map(&:attributes))
          end
        end
      end

      def mask
        self.columns_to_mask.each do |column, mask_config|
          mask_type = mask_config["type"]
          masked = MaskedDataGenerator.generate_masked_value(mask_type, mask_config)
          public_send("#{column}=", masked)
        end
      end
    end
  end
end
