require "spec_helper"

#rubocop:disable Style/BracesAroundHashParameters, Metrics/BlockLength
RSpec.describe CertifyActivityLog do
  describe "get activities operations using where" do
    context "for getting activities" do
      let(:mock) { ActivitySpecHelper.mock_activities_sym }
      let(:activities) { CertifyActivityLog::Activity.where({recipient_id: 1}) }
      let(:body) { activities[:body] }

      before do
        Excon.stub({}, body: mock.to_json, status: 200)
      end

      it "will return a good status code" do
        expect(activities[:status]).to eq(200)
      end

      it "will return an array of activities" do
        expect(body.length).to be > 0
      end

      it "will contain valid activities attributes" do
        expect(body[0][:id]).to eq(mock[0]["id"])
      end
    end

    context "with no params" do
      let(:activities) { CertifyActivityLog::Activity.where }
      let(:body) { activities[:body] }

      it "will return an error message" do
        expect(body).to eq(described_class.bad_request[:body])
      end
      it "will return a 400" do
        expect(activities[:status]).to eq(described_class.bad_request[:status])
      end
    end

    context "with bad parameters" do
      let(:activities) { CertifyActivityLog::Activity.where({foo: 'bar'}) }
      let(:body) { activities[:body] }

      it "will return an error message when a bad parameter is sent" do
        expect(body).to eq(described_class.unprocessable[:body])
      end

      it "will return a 422 http status" do
        expect(activities[:status]).to eq(described_class.unprocessable[:status])
      end
    end

    # this will work if the API is disconnected, but I can't figure out how to
    # fake the Excon connection to force it to fail in a test env.
    context "with api not found" do
      let(:activities) { CertifyActivityLog::Activity.where({id: 1}) }
      let(:error) { described_class.service_unavailable 'Excon::Error::Socket' }

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
        expect(activities[:body]).to eq(error[:body])
      end
    end
  end
end
