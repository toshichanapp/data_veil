# frozen_string_literal: true

require "spec_helper"

RSpec.describe DataVeil::Mask::Base do
  let(:database_config_path) { Pathname(__dir__).join("../../fixtures/config/database.yml") }
  let(:masking_config_path) { Pathname(__dir__).join("../../fixtures/config/masking.yml") }

  before(:all) do
    # Set up the masking configuration
    DataVeil::Masking::Initializer.setup(
      database_config_path: Pathname(__dir__).join("../../fixtures/config/database.yml"),
      masking_config_path: Pathname(__dir__).join("../../fixtures/config/masking.yml"),
      environment: "test"
    )

    # Load database configuration
    config = YAML.load_file(Pathname(__dir__).join("../../fixtures/config/database.yml"), aliases: true)["test"]
    ActiveRecord::Base.configurations = config
    ActiveRecord::Base.establish_connection(:default)
  end

  let(:test_class) do
    DataVeil::Mask::User
  end

  describe ".verify_non_production_host!" do
    it "does not raise an error for test database" do
      expect { test_class.verify_non_production_host! }.not_to raise_error
    end

    it "prints a message about connected hosts" do
      expect { test_class.verify_non_production_host! }.to output(/Connected to the same host as/).to_stdout
    end
  end

  describe ".columns_to_mask" do
    it "returns the columns to mask" do
      expect(test_class.columns_to_mask).to eq({ "email" => "email", "name" => "string", "password" => "password",
                                                 "phone" => "tel" })
    end
  end

  describe ".mask_all!" do
    before do
      # Create test data
      test_class.create!(email: "test@example.com", name: "Test User", password: "password123", phone: "123-456-7890")
    end

    after do
      # Clean up test data
      test_class.delete_all
    end

    it "masks all records" do
      test_class.mask_all!
      masked_record = test_class.first

      expect(masked_record.email).to match(/\A[0-9a-f]{20}@example\.com\z/)
      expect(masked_record.name).to match(/\A[0-9a-f]{20}\z/)
      expect(masked_record.password).to match(/\A[0-9a-f]{20}\z/)
      expect(masked_record.phone).to match(/\A090-0[0-9a-f]{3}-[0-9a-f]{8}\z/)
    end
  end

  describe "#mask" do
    let(:instance) do
      test_class.new(email: "test@example.com", name: "Test User", password: "password123", phone: "123-456-7890")
    end

    it "masks email correctly" do
      instance.mask
      expect(instance.email).to match(/\A[0-9a-f]{20}@example\.com\z/)
    end

    it "masks name correctly" do
      instance.mask
      expect(instance.name).to match(/\A[0-9a-f]{20}\z/)
    end

    it "masks password correctly" do
      instance.mask
      expect(instance.password).to match(/\A[0-9a-f]{20}\z/)
    end

    it "masks phone correctly" do
      instance.mask
      expect(instance.phone).to match(/\A090-0[0-9a-f]{3}-[0-9a-f]{8}\z/)
    end

    it "raises ArgumentError for unknown mask type" do
      allow(test_class).to receive(:columns_to_mask).and_return({ "unknown" => "invalid_type" })
      expect { instance.mask }.to raise_error(ArgumentError, "Unknown mask type: invalid_type")
    end
  end

  describe ".list_classes" do
    let!(:test_mask_class) do
      DataVeil::Mask.const_set(:TestMaskClass, Class.new(DataVeil::Mask::Base) { self.abstract_class = false })
    end

    let!(:abstract_mask_class) do
      DataVeil::Mask.const_set(:AbstractMaskClass, Class.new(DataVeil::Mask::Base) { self.abstract_class = true })
    end

    after do
      DataVeil::Mask.send(:remove_const, :TestMaskClass)
      DataVeil::Mask.send(:remove_const, :AbstractMaskClass)
    end

    it "returns a list of non-abstract descendant classes" do
      expect(DataVeil::Mask::Base.list_classes).to include(test_mask_class)
      expect(DataVeil::Mask::Base.list_classes).not_to include(abstract_mask_class)
    end
  end
end
