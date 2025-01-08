# frozen_string_literal: true

module DataVeil
  module Masking
    class Initializer
      def self.setup(database_config_path:, masking_config_path:, environment:)
        puts "environment: #{environment}"
        puts "database_config_path: #{database_config_path}"
        load_database_config(database_config_path, environment)
        puts "masking_config_path: #{masking_config_path}"
        create_mask_classes(masking_config_path)
      end

      def self.load_database_config(database_config_path, environment)
        db_config = YAML.safe_load(ERB.new(File.read(database_config_path)).result, aliases: true)
        ActiveRecord::Base.configurations = db_config[environment]
      end

      def self.create_mask_classes(masking_config_path)
        config = YAML.load_file(masking_config_path)
        config.flat_map do |database_name, tables|
          base_class_name = "#{database_name.classify}Record"
          base_klass = Class.new(ActiveRecord::Base) do
            include DataVeil::Mask::Base
            self.abstract_class = true
          end
          # connects_toは Anonymous class is not allowed.なので命名する。
          base_class = DataVeil::Mask.const_set(base_class_name, base_klass)
          base_class.connects_to database: { writing: database_name.to_sym, reading: database_name.to_sym }

          tables.map do |table_name, columns|
            Class.new(base_class) do
              self.table_name = table_name
              class_attribute :columns_to_mask, default: columns
            end
          end
        end
      end
    end
  end
end
