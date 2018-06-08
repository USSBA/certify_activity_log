require "spec_helper"
require "certify_activity_log"
require 'support/vcr_helper'

#rubocop:disable Metrics/BlockLength
RSpec.describe CertifyActivityLog do
  describe "create activities with api connection", :vcr do
    Excon.stubs.clear
    let(:mock) { ActivitySpecHelper.symbolize ActivitySpecHelper.real_activity }
    let(:activity) { CertifyActivityLog::Activity.create_soft(mock) }
    let(:body) { activity[:body] }

    # configure for vcr test
    before do
      Excon.defaults[:mock] = false
      Excon.stubs.clear
      VCR.configure do |config|
        config.hook_into :excon
        config.allow_http_connections_when_no_cassette = false
      end
      described_class.configure do |config|
        config.api_url = "http://localhost:3005"
      end
    end

    VCR.use_cassette 'api connection' do
      it "will return the correct post response" do
        expect(activity[:status]).to eq(200)
      end
    end

    # restore configuration for exconn stubs
    after do
      VCR.configure do |config|
        config.allow_http_connections_when_no_cassette = true
      end
      described_class.configure do |config|
        config.api_url = "http://foo.bar/"
      end
      Excon.stubs.clear
      Excon.defaults[:mock] = true
      Excon.stub({}, body: { message: 'Fallback stub response' }.to_json, status: 598)
    end
  end
end
