require 'spec_helper'

describe NetSuite::Configuration do
  let(:config) { NetSuite::Configuration }

  before do
    config.reset!
  end

  describe '#reset!' do
    it 'clears the attributes hash' do
      config.attributes[:blah] = 'something'
      expect(config.attributes).not_to be_empty
      config.reset!
      expect(config.attributes).to be_empty
    end
  end

  describe '#filters' do
    it 'filters out email and password by default' do
      expect(config.filters).to eq([:password, :email, :consumerKey, :token])
    end

    it 'allows the user to set custom filters' do
      config.filters([:special])

      expect(config.filters).to eq([:special])
    end
  end

  describe '#connection' do
    before(:each) do
      # reset clears out the password info
      config.email       'me@example.com'
      config.password    'me@example.com'
      config.account     1023
      config.wsdl        "my_wsdl"
      config.api_version "2012_2"
    end

    it 'returns a Savon::Client object that allows requests to the service' do
      expect(config.connection).to be_kind_of(Savon::Client)
    end
  end

  describe '#wsdl' do
    context 'when the wsdl has been set' do
      before do
        config.wsdl = 'https://system.sandbox.netsuite.com/wsdl/v2011_2_0/netsuite.wsdl'
      end

      it 'returns a path to the WSDL to use for the API' do
        expect(config.wsdl).to eql('https://system.sandbox.netsuite.com/wsdl/v2011_2_0/netsuite.wsdl')
      end
    end

    context 'when the wsdl has not been set' do
      it 'returns a path to the WSDL to use for the API' do
        expect(config.wsdl).to eq("https://webservices.netsuite.com/wsdl/v2015_1_0/netsuite.wsdl")
      end
    end

    context 'when the wsdl has not been set, but the API has been set' do
      it 'should correctly return the full HTTP sandbox URL' do
        config.api_version '2013_1'
        config.sandbox false
        expect(config.wsdl).to eql('https://webservices.netsuite.com/wsdl/v2013_1_0/netsuite.wsdl')
      end
    end

    context 'when the API and wsdl domain have been set' do
      it 'should correctly modify the full wsdl path' do
        config.sandbox = false
        config.api_version '2014_1'
        config.wsdl_domain = 'system.na1.netsuite.com'

        expect(config.wsdl).to eql('https://system.na1.netsuite.com/wsdl/v2014_1_0/netsuite.wsdl')
      end
    end

    context '#cache_wsdl' do
      it 'stores the client' do
        expect(config.wsdl_cache).to be_empty
        config.cache_wsdl("whatevs")
        expect(config.wsdl_cache).to eq(
          {config.wsdl => "whatevs"}
        )
      end

      it 'doesnt write over old values' do
        config.class_exec(config.api_version, config.wsdl) do |api, wsdl|
          wsdl_cache[wsdl] = "old value"
        end
        config.cache_wsdl("new value")

        expect(config.wsdl_cache.values.first).to eq("old value")
      end

      it 'handles a nil cache' do
        config.class_eval { @wsdl_cache = nil }
        config.cache_wsdl("whatevs")
        expect(config.wsdl_cache).to eq(
          {config.wsdl => "whatevs"}
        )
      end

      it 'can cache multiple values' do
        config.class_exec("2020_2", "fake wsdl") do |api, wsdl|
          wsdl_cache[wsdl] = "old value"
        end
        expect(config.wsdl_cache.keys.count).to eq 1
        config.cache_wsdl("new value")

        expect(config.wsdl_cache.keys.count).to eq 2
      end
    end

    context '#cached_wsdl' do
      it 'returns wsdl (xml)' do
        config.class_exec(config.api_version, config.wsdl) do |api, wsdl|
          wsdl_cache[wsdl] = "xml wsdl string"
        end
        expect( config.cached_wsdl ).to eq "xml wsdl string"
      end

      it 'stores client xml' do
        client = double(:savon_client)
        allow(client).to receive(:is_a?).with(String).and_return(false)
        allow(client).to receive(:is_a?).with(Savon::Client).and_return(true)
        wsdl_dbl = double(:wsdl, xml: "xml wsdl")
        client.instance_exec(wsdl_dbl) {|wsdl| @wsdl = wsdl }
        config.class_exec(config.api_version, config.wsdl, client) do |api, wsdl, c|
          wsdl_cache[wsdl] = c
        end

        expect( config.wsdl_cache.values.first ).to eq client
        expect( config.cached_wsdl ).to eq "xml wsdl"
        expect( config.wsdl_cache.values.first ).to eq "xml wsdl"
      end

      it 'handles a nil cache' do
        config.class_eval { @wsdl_cache = nil }
        expect( config.cached_wsdl ).to eq nil
      end

      it 'handles an empty cache' do
        expect(config.wsdl_cache).to be_empty
        expect( config.cached_wsdl ).to eq nil
      end
    end
  end

  describe '#auth_header' do
    context 'when doing user authentication' do
      before do
        config.account  = 1234
        config.email    = 'user@example.com'
        config.password = 'myPassword'
      end

      it 'returns a hash representation of the authentication header' do
        expect(config.auth_header).to eql({
          'platformMsgs:passport' => {
            'platformCore:account'  => '1234',
            'platformCore:email'    => 'user@example.com',
            'platformCore:password' => 'myPassword',
            'platformCore:role'     => { :@internalId => '3' },
          }
        })
      end
    end

    context 'when doing token authentication' do
      before do
        config.account         = 1234
        config.consumer_key    = 'consumer_key'
        config.consumer_secret = 'consumer_secret'
        config.token_id        = 'token_id'
        config.token_secret    = 'token_secret'
      end

      it 'returns tokenPassport object' do
        expect(config.auth_header.has_key?('platformMsgs:tokenPassport')).to be_truthy
      end

      it 'returns proper elements of tokenPassport' do
        expect(config.auth_header['platformMsgs:tokenPassport']['platformCore:account']).to eql('1234')
        expect(config.auth_header['platformMsgs:tokenPassport']['platformCore:consumerKey']).to eql('consumer_key')
        expect(config.auth_header['platformMsgs:tokenPassport']['platformCore:token']).to eql('token_id')
        expect(config.auth_header['platformMsgs:tokenPassport'][:attributes!]).to eql({ 'platformCore:signature' => { 'algorithm' => 'HMAC-SHA256' } })

        expect(config.auth_header['platformMsgs:tokenPassport'].has_key?('platformCore:nonce')).to be_truthy
        expect(config.auth_header['platformMsgs:tokenPassport'].has_key?('platformCore:timestamp')).to be_truthy
        expect(config.auth_header['platformMsgs:tokenPassport'].has_key?('platformCore:signature')).to be_truthy
      end
    end
  end

  describe '#soap_header' do
    before do
      config.email    = 'user@example.com'
      config.password = 'myPassword'
      config.account  = 1234
    end

    it 'adds a new header to the soap header' do
      config.soap_header = {
        'platformMsgs:preferences' => {
          'platformMsgs:ignoreReadOnlyFields' => true,
        }
      }
      expect(config.soap_header).to eql({
        'platformMsgs:preferences' => {
          'platformMsgs:ignoreReadOnlyFields' => true,
        }
      })
    end
  end

  describe '#email' do
    context 'when the email has been set' do
      before do
        config.email = 'test@example.com'
      end

      it 'returns the email' do
        expect(config.email).to eql('test@example.com')
      end
    end

    context 'when the email has not been set' do
      it 'raises a ConfigurationError' do
        expect(config.email).to be_nil
      end
    end
  end

  describe '#password' do
    context 'when the password has been set' do
      before do
        config.password = 'password'
      end

      it 'returns the password' do
        expect(config.password).to eql('password')
      end
    end

    context 'when the password has not been set' do
      it 'raises a ConfigurationError' do
        expect(config.password).to be_nil
      end
    end
  end

  describe '#account' do
    context 'when the account has been set' do
      before do
        config.account = 4321
      end

      it 'returns the account' do
        expect(config.account).to eql(4321)
      end
    end

    context 'when the account has not been set' do
      it 'raises a ConfigurationError' do
        expect(config.account).to be_nil
      end
    end
  end


  describe '#role' do
    context 'when no role is defined' do
      it 'defaults to "3"' do
        expect(config.role).to eq("3")
      end
    end
  end

  describe '#role=' do
    it 'sets the role according to the input value' do
      config.role = "6"
      expect(config.role).to eq("6")
    end
  end

  describe '#api_version' do
    context 'when no api_version is defined' do
      it 'defaults to 2015_1' do
        expect(config.api_version).to eq('2015_1')
      end
    end
  end

  describe '#api_version=' do
    context 'when api version is defined' do
      it 'sets the api_version of the application' do
        # retrieve wsdl to ensure setting the api works when the wsdl is cached
        config.wsdl
        config.api_version = '1980_1'

        expect(config.api_version).to eq('1980_1')
        expect(config.wsdl).to include('1980_1')
      end
    end
  end

  describe "#credentials" do
    context "when none are defined" do
      skip "should properly create the auth credentials" do

      end
    end

    context "when they are defined" do
      it "should properly replace the default auth credentials" do

      end
    end
  end

  it '#silent' do
    config.silent = false
    expect(config.silent).to eq(false)

    config.silent = true
    expect(config.silent).to eq(true)
  end

  it '#wsdl_domain' do
    # NOTE wsdl is tested since it uses wsdl_domain
    expect(config.wsdl_domain).to eq('webservices.netsuite.com')

    config.wsdl_domain('custom.domain.com')
    expect(config.wsdl_domain).to eq('custom.domain.com')
    expect(config.wsdl).to include('custom.domain.com')

    config.sandbox = true
    expect(config.wsdl_domain).to eq('webservices.sandbox.netsuite.com')
    expect(config.wsdl).to include('webservices.sandbox.netsuite.com')
  end

  describe '#logger=' do
    let(:logger) { Logger.new(nil) }

    before do
      config.logger = logger
    end

    it 'sets logger' do
      expect(config.logger).to eql(logger)
    end
  end

end
