require "spec_helper"

RSpec.describe CertifyActivityLog do
  it "will have a version number" do
    expect(described_class::VERSION::STRING).not_to be nil
  end

  it "will have an endpoint url" do
    expect(described_class.configuration.api_url).to eq('http://foo.bar/')
  end

  it "will specify the activity API version" do
    expect(described_class.configuration.activity_api_version).to eq(1)
  end

  it "will have a Activity class" do
    expect(described_class::Activity.new).to be
  end
end
