require "spec_helper"

#rubocop:disable Style/BracesAroundHashParameters, Metrics/BlockLength
module V1
  RSpec.describe CertifyActivityLog do
    before do
      CertifyActivityLog.configuration.activity_api_version = 1
    end

    describe "get activities operations using export" do
      context "for exporting activities" do
        let(:mock) { ActivitySpecHelper.mock_activity_csv }
        let(:activities) { CertifyActivityLog::Activity.where({application_id: 1}) }
        let(:body) { activities[:body] }

        before do
          Excon.stub({}, body: mock.to_json, status: 200)
        end

        it "will return a good status code" do
          expect(activities[:status]).to eq(200)
        end

        it "will return a string of activities content" do
          expect(body.length).to be > 0
        end
      end

      context "with no params" do
        let(:activities) { CertifyActivityLog::Activity.export }
        let(:body) { activities[:body] }

        it "will return an error message" do
          expect(body).to eq(described_class.bad_request[:body])
        end
        it "will return a 400" do
          expect(activities[:status]).to eq(described_class.bad_request[:status])
        end
      end

      context "with bad parameters" do
        let(:activities) { CertifyActivityLog::Activity.export({foo: 'bar'}) }
        let(:body) { activities[:body] }

        it "will return an error message when a bad parameter is sent" do
          expect(body).to eq(described_class.bad_request[:body])
        end

        it "will return a 422 http status" do
          expect(activities[:status]).to eq(described_class.bad_request[:status])
        end
      end

      # this will work if the API is disconnected, but I can't figure out how to
      # fake the Excon connection to force it to fail in a test env.
      context "with api not found" do
        let(:activities) { CertifyActivityLog::Activity.export({application_id: 1}) }
        let(:error_type) { "SocketError" }
        let(:error) { described_class.service_unavailable error_type }

        before do
          CertifyActivityLog::Resource.clear_connection
          Excon.defaults[:mock] = false
        end

        after do
          CertifyActivityLog::Resource.clear_connection
          Excon.defaults[:mock] = true
        end

        it "will return a 503" do
          expect(activities[:status]).to eq(error[:status])
        end

        it "will return an error message" do
          expect(activities[:body]).to match(/#{error_type}/)
        end
      end
    end
  end
end
