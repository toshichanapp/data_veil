# frozen_string_literal: true

require "spec_helper"

RSpec.describe DataVeil::Masking::Initializer do
  let(:database_config_path) { Pathname(__dir__).join "../../fixtures/config/database.yml" }
  let(:masking_config_path) { Pathname(__dir__).join "../../fixtures/config/masking.yml" }
  let(:environment) { "test" }

  describe ".setup" do
    it "loads the database configuration" do
      described_class.setup(database_config_path: database_config_path, masking_config_path: masking_config_path,
                            environment: environment)
    end

    it "creates mask classes" do
      described_class.setup(database_config_path: database_config_path, masking_config_path: masking_config_path,
                            environment: environment)
      expect(DataVeil::Mask.const_defined?("DefaultRecord")).to be true
      expect(DataVeil::Mask.const_defined?("User")).to be true
    end
  end
end
