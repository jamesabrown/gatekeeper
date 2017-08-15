require File.expand_path '../test_helper.rb', __FILE__

describe 'Missing ENV variables' do
  ['/', '/whitelist/1', '/expire', 'random'].each do |path|
    it "return an error if GK_SGID is not provided for path #{path}" do
      expect { get path }.to raise_error('GK_SGID must be set')
    end
  end

  ['/', '/whitelist/1', '/expire', 'random'].each do |path|
    it "return an error if GK_AUTH_TOKEN is not provided for path #{path}" do
      ENV['GK_SGID'] = 'GK_SGID'
      expect { get path }.to raise_error('GK_AUTH_TOKEN must be set')
    end
  end
end

describe 'Authorized access' do
  before :each do
    ENV['GK_SGID'] = 'GK_SGID'
    ENV['GK_AUTH_TOKEN'] = 'GK_AUTH_TOKEN'
  end
  it 'should return the correct response if the ENV variables are set' do
    get '/', nil, 'HTTP_KEY' => 'GK_AUTH_TOKEN'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('What are we adding to the whitelist?')
  end
end
