require "spec_helper"

#rubocop:disable Style/BracesAroundHashParameters, Metrics/BlockLength
RSpec.describe CertifyActivityLog do
  ActivitySpecHelper.mock_activity_types.each do |type, activity_mock|
    describe "create operations for #{type}" do
      context "for creating new activities" do
        let(:mock) { ActivitySpecHelper.symbolize activity_mock }
        let(:activity) { CertifyActivityLog::Activity.create_soft(mock) }
        let(:body) { activity[:body] }

        # before do
        #   mock = ActivitySpecHelper.symbolize activity_mock 
        #   activity = CertifyActivityLog::Activity.create_soft(mock) 
        #   body = activity[:body] 
        #   byebug
        #   # Excon.stub({}, body: mock.to_json, status: 201)
        # end

        it "will return the correct post response" do
          expect(activity[:status]).to eq(201)
        end
        it "will return the correct activity object" do
          expect(body["id"]).to eq(mock[:id])
        end
        it "will handle being given a string" do
          expect(body["recipient_id"]).to eq(mock[:recipient_id])
        end
        context "containing all required parameters" do
          it "will have the activty_type parameter" do
            expect(activity[:body]["activity_type"]).not_to eq(nil)
          end

          it "will have the event_type parameter" do
            expect(activity[:body]["event_type"]).not_to eq(nil)
          end

          it "will have the subtype parameter" do
            expect(activity[:body]["subtype"]).not_to eq(nil)
          end

          it "will have the recipient_id parameter" do
            expect(activity[:body]["recipient_id"]).not_to eq(nil)
          end

          it "will have the application_id parameter" do
            expect(activity[:body]["application_id"]).not_to eq(nil)
          end
        end
      end
      context "for creating activities with soft validation" do
        let(:first_activity) { ActivitySpecHelper.symbolize activity_mock }
        let(:second_activity) { ActivitySpecHelper.symbolize activity_mock }
        let(:invalid_activity) { ActivitySpecHelper.symbolize activity_mock }

        it "will create a set of valid activities" do
          Excon.stub({}, status: 201)
          response = CertifyActivityLog::Activity.create_soft([first_activity, second_activity])
          expect(response[:status]).to match(201)
        end
        it "will handle a set of invalid activities" do
          Excon.stub({}, status: 207)
          response = CertifyActivityLog::Activity.create_soft([first_activity, invalid_activity])
          expect(response[:status]).to match(207)
        end
      end
      context "for creating activities with strict validation" do
        let(:first_activity) { ActivitySpecHelper.symbolize activity_mock }
        let(:second_activity) { ActivitySpecHelper.symbolize activity_mock }
        let(:invalid_activity) { ActivitySpecHelper.symbolize activity_mock }

        it "will create a set of valid activities" do
          Excon.stub({}, status: 201)
          response = CertifyActivityLog::Activity.create_strict([first_activity, second_activity])
          expect(response[:status]).to match(201)
        end
        it "will handle a set of invalid activities" do
          Excon.stub({}, status: 400)
          response = CertifyActivityLog::Activity.create_strict([first_activity, invalid_activity])
          expect(response[:status]).to match(400)
        end
      end
      context "with empty parameters" do
        let(:bad_activity) { CertifyActivityLog::Activity.create_soft }

        it 'will return a status code of 400' do
          expect(bad_activity[:status]).to eq(described_class.bad_request[:status])
        end

        it 'will return an error message' do
          expect(bad_activity[:body]).to eq(described_class.bad_request[:body])
        end
      end

      context "with bad parameters" do
        let(:bad_activity) { CertifyActivityLog::Activity.create_soft({foo: 'bar'}) }

        it 'will return a status code of 422' do
          expect(bad_activity[:status]).to eq(described_class.unprocessable[:status])
        end

        it 'will return an error message' do
          expect(bad_activity[:body]).to eq(described_class.unprocessable[:body])
        end
      end

      # this will work if the API is disconnected, but I can't figure out how to
      # fake the Excon connection to force it to fail in a test env.
      context "with api not found" do
        let(:activity) { CertifyActivityLog::Activity.create_soft({id: 1}) }
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
          expect(activity[:status]).to eq(error[:status])
        end

        it "will return an error message" do
          expect(activity[:body]).to match(/#{error_type}/)
        end
      end
    end
  end
end
