# RSpec.describe BotAuthService do
#   let(:service) { BotAuthService.new }
#   before do
#     WebMock.allow_net_connect!(net_http_connect_on_start: true)
#   end
  
#   after do
#     WebMock.disable_net_connect!(allow_localhost: true)
#   end

#   before do
#     stub_request(:post, "http://ai_chat:3000/api/signup").
#       with(
#         body: "{\"user\":{\"name\":\"Muul\",\"email\":\"Muul@diid\",\"nickname\":\"muul_tg_bot\",\"password\":\"password_muul\"}}",
#         headers: {
#           'Accept'=>'application/json',
#           'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
#           'Content-Type'=>'application/json',
#           'User-Agent'=>'Faraday v2.7.10'
#         }
#       ).
#       to_return(status: 200, body: "{\"jwt_token\":\"mocked_jwt_token_for_signup\"}", headers: {})
#   end
  
#   context "when JWT token is not present" do
#     before do
#       allow(service).to receive(:fetch_token_from_storage).and_return(nil)
#       allow(service).to receive(:fetch_refresh_token_from_storage).and_return(nil)
#     end

#     it "should authenticate the bot" do
#       expect(service.initialize_bot).to be_truthy
#       expect(service.send(:jwt_token_present?)).to be_truthy
#     end
#   end

#   context "when JWT token is present" do
#     before do
#       allow(service).to receive(:fetch_token_from_storage).and_return("mocked_jwt_token")
#       allow(service).to receive(:fetch_refresh_token_from_storage).and_return("mocked_refresh_token")
#     end

#     it "should not re-authenticate the bot" do
#       expect(service).not_to receive(:signup)
#       expect(service).not_to receive(:login)
#       expect(service.initialize_bot).to be_truthy
#     end
#   end
# end
