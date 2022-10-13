require 'spec_helper'
require 'aws_credentials'
require 'integer'

RSpec.describe '#aws_credentials' do
  it 'provides credentials' do
    creds = AwsCredentials.instance.credentials
    expect(creds.secret_access_key).to eq 'secret'
    expect(creds.access_key_id).to eq 'access'
    expect(AwsCredentials.instance.refresh_time).to be > Time.now.to_i
  end
 
  it 'expires credentials' do
    creds = AwsCredentials.instance.credentials
    expect(creds.secret_access_key).to eq 'secret'
    expect(creds.access_key_id).to eq 'access'
    first_time = AwsCredentials.instance.refresh_time
    Timecop.freeze(360.minutes) do
      creds = AwsCredentials.instance.credentials
      expect(creds.secret_access_key).to eq 'secret'
      expect(AwsCredentials.instance.refresh_time).to be >= first_time + 360.minutes
    end
  end
end
  
