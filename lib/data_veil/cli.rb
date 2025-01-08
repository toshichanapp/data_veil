# frozen_string_literal: true

module DataVeil
  class CLI < Thor
    SUCCESS_EXIT_CODE = 0
    ERROR_EXIT_CODE = 1

    desc "mask", "Run masking process"
    option :database_config_path,
           aliases: "-d",
           default: "./config/mask_database.yml",
           desc: "Path to the database configuration file"
    option :masking_config_path,
           aliases: "-m",
           default: "./config/masking.yml",
           desc: "Path to the masking configuration file"
    option :environment,
           aliases: "-e",
           default: "development",
           desc: "Environment"

    def mask
      masked_classes = DataVeil::Masking::Initializer.setup(
        database_config_path: options[:database_config_path],
        masking_config_path: options[:masking_config_path],
        environment: options[:environment]
      )
      run_mask_all_on_generated_classes(masked_classes)
      SUCCESS_EXIT_CODE
    rescue StandardError => e
      puts e.inspect
      ERROR_EXIT_CODE
    end

    private

    def run_mask_all_on_generated_classes(masked_classes)
      masked_classes.each do |klass|
        puts "Running mask_all! on #{klass.table_name}"
        klass.mask_all!
      end
    end
  end
end
