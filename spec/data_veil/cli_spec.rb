# frozen_string_literal: true

RSpec.describe DataVeil::CLI do
  let(:argv) { [] }
  let(:cli) { described_class.new(argv) }

  describe "#run" do
    before do
      allow(DataVeil::Masking::Initializer).to receive(:setup)
    end

    context "when mask_all! is called on generated classes" do
      let!(:test_class) do
        Class.new(DataVeil::Mask::Base) do
          def self.name
            "TestMaskClass"
          end
        end
      end

      before do
        allow(DataVeil::Mask::Base).to receive(:list_classes).and_return([test_class])
        allow(test_class).to receive(:mask_all!)
      end

      it "runs mask_all! on all generated classes" do
        cli.run
        expect(test_class).to have_received(:mask_all!)
      end
    end

    it "calls Initializer.setup with default options" do
      expect(DataVeil::Masking::Initializer).to receive(:setup).with(
        database_config_path: "./config/database.yml",
        masking_config_path: "./config/masking.yml",
        environment: "elopment"
      )
      cli.run
    end
  end

  describe "#parse_options" do
    context "with custom options" do
      let(:argv) do
        ["--database-config", "./config/custom_database.yml", "--masking-config", "./config/custom_masking.yml",
         "--environment", "test"]
      end

      it "parses command line options" do
        options = cli.parse_options
        expect(options[:database_config_path]).to eq("./config/custom_database.yml")
        expect(options[:masking_config_path]).to eq("./config/custom_masking.yml")
        expect(options[:environment]).to eq("test")
      end
    end

    context "with default options" do
      let(:argv) { [] }

      it "returns default options" do
        options = cli.parse_options
        expect(options[:database_config_path]).to eq("./config/database.yml")
        expect(options[:masking_config_path]).to eq("./config/masking.yml")
        expect(options[:environment]).to eq("elopment")
      end
    end
  end
end
