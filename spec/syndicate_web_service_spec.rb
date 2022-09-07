require 'spec_helper'
require 'syndicate_web_service'

RSpec.describe '#syndicate web service' do
  let(:discord_id) { '2134658448' }
  let(:kick_code) { '56ldtzDOy5u2PyGM' }
  shared_examples 'a proper request' do
    it 'sends a proper request' do
      expect(result).to be_a Net::HTTPOK
    end
  end

  before(:each) do
    Timecop.freeze(Time.parse('Tue Oct 19 15:37:00 PDT 2021').utc)
  end

  context  'POST register_with_syndicate_web_service' do
    let(:result) { SyndicateWebService
        .new
        .register_with_syndicate_web_service(kick_code, discord_id) }
    before(:each) do
      stub_request(:post, "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/auth/register/by-kick-code/56ldtzDOy5u2PyGM/discord-id/2134658448")
        .with(
             headers: {
               'Accept'=>'*/*',
               'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
               'Authorization'=>'AWS4-HMAC-SHA256 Credential=access/20211019/us-west-2/execute-api/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=26cfd87dc74cd138afd9001ca92340e6de35cfa4d91090e93867eb1161db81bc',
               'Host'=>'knopfnsxoh.execute-api.us-west-2.amazonaws.com',
               'User-Agent'=>'Ruby',
               'X-Amz-Content-Sha256'=>'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                'X-Amz-Date'=>'20211019T223700Z'
              })
        .to_return(status: 200, body: "", headers: {})
    end

    it_behaves_like 'a proper request'
  end

  context 'GET get_user_record' do
    let(:result) { SyndicateWebService
        .new
        .get_user_record(discord_id) }
    before(:each) do
      stub_request(:get, "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/auth/user/by-discord-id/2134658448")
        .with(
              headers: {
                'Accept'=>'*/*',
                'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Authorization'=>'AWS4-HMAC-SHA256 Credential=access/20211019/us-west-2/execute-api/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=3a9805bf2bba8f75a4aa0256bb28e40534df12370cc3d52fdee7a55f44fec1d7',
                'Host'=>'knopfnsxoh.execute-api.us-west-2.amazonaws.com',
                'User-Agent'=>'Ruby',
                'X-Amz-Content-Sha256'=>'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
                'X-Amz-Date'=>'20211019T223700Z'
              })
        .to_return(status: 200, body: "", headers: {})
    end

    it_behaves_like 'a proper request'
  end  
  
  context 'POST to send_game_to_syndicate_web_service' do
    let(:body) { File.read('spec/mocks/new-game.json') }
    let(:result) { SyndicateWebService
        .new
        .send_game_to_syndicate_web_service(body) }
    before(:each) do
       stub_request(:post, "https://knopfnsxoh.execute-api.us-west-2.amazonaws.com/Prod/auth/game")
         .with(
               body: body,
               headers: {
                 'Accept'=>'*/*',
                 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                 'Authorization'=>'AWS4-HMAC-SHA256 Credential=access/20211019/us-west-2/execute-api/aws4_request, SignedHeaders=host;x-amz-content-sha256;x-amz-date, Signature=8fb30a50d6b32225c284f5455109be10b63223166b65396b9b2e1a83b90d96fd',
                 'Host'=>'knopfnsxoh.execute-api.us-west-2.amazonaws.com',
                 'User-Agent'=>'Ruby',
                 'X-Amz-Content-Sha256'=>'df90f61398053a24602e04c21223f1a30880e971a7cad8f0b3ac8aede753c9ed',
                 'X-Amz-Date'=>'20211019T223700Z'
               })
        .to_return(status: 200, body: "", headers: {})
    end
    
    it_behaves_like 'a proper request'
  end
end
