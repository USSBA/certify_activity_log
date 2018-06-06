require "spec_helper"
require "certify_activity_log"
require 'support/vcr_helper.rb'

#rubocop:disable Style/BracesAroundHashParameters, Metrics/BlockLength
RSpec.describe CertifyActivityLog do
  describe "create activities with api connection", :vcr do
      
    let(:mock) { ActivitySpecHelper.symbolize  ActivitySpecHelper.real_activity}
    let(:activity) { CertifyActivityLog::Activity.create_soft(mock) }
    let(:body) { activity[:body] }

    #configure for vcr test
    before do
      Excon.defaults[:mock] = false
      VCR.configure do |config|
        config.allow_http_connections_when_no_cassette = false
      end
      CertifyActivityLog.configure do |config|
        config.api_url ="http://localhost:3005"
      end
    end

    VCR.use_cassette 'create with api connection' do
        it "will return the correct post response" do
            byebug
            expect(activity[:status]).to eq(200)
        end
    end

    # restore configuration for exconn stubs
    after(:all) do
      VCR.configure do |config|
        config.allow_http_connections_when_no_cassette = true
      end
      CertifyActivityLog.configure do |config|
        config.api_url ="http://foo.bar/"
      end
      Excon.defaults[:mock] = true
      Excon.stub({}, body: { message: 'Fallback stub response' }.to_json, status: 598)
    end
    VCR.configure do |config|
        config.allow_http_connections_when_no_cassette = true
    end
  end
end