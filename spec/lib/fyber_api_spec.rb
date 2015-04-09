require 'rails_helper'

describe FyberApi do
  before(:each) do
    @time_now = Time.parse("09/04/2015")
    allow(Time).to receive(:now).and_return(@time_now)
  end

  it "::API_URL" do
    expect(FyberApi::API_URL).to eq('http://api.sponsorpay.com/feed/v1/offers.json')
  end

  it "#default_options" do
    fyber_api = FyberApi
    expect(fyber_api.default_options).to eq({
      appid: 123,
      device_id: 456,
      locale: 'de',
      ip: '1.1.1.1',
      offer_types: 112,
      timestamp: Time.now.to_i})

    expect(fyber_api.app_id).to eq(123)
    expect(fyber_api.device_id).to eq(456)
    expect(fyber_api.locale).to eq('de')
    expect(fyber_api.ip).to eq('1.1.1.1')
    expect(fyber_api.offer_types).to eq(112)
    expect(fyber_api.api_key).to eq(789)
  end

  describe '#query_string' do
    it "accepts empty string" do
      query_string = FyberApi.query_string()
      expect(query_string).to eq('appid=123&device_id=456&ip=1.1.1.1&locale=de&offer_types=112&timestamp=1428530400')
    end

    it "accepts additional options" do
      query_string = FyberApi.query_string(uid: "player1", page: 1)
      expect(query_string).to eq('appid=123&device_id=456&ip=1.1.1.1&locale=de&offer_types=112&page=1&timestamp=1428530400&uid=player1')
    end
  end

  let(:query) {"appid=123&device_id=456&ip=1.1.1.1&locale=de&offer_types=112&page=1&timestamp=1428530400&uid=player1"}

  describe "#hashkey" do
    it "should raise ArgumentError for argument that is not a string" do
      expect{FyberApi.hashkey_calculation(nil)}.to raise_error(ArgumentError)
    end

    it "returns SHA1" do
      expect(FyberApi.hashkey_calculation(query)).to eq("6935d641aee426fbf5c6fc7814747a47099ca48b")
    end

    it "returns SHA1 when string is empty" do
      expect(FyberApi.hashkey_calculation("")).to eq("30a44399d4d6844281d2238be8e81d309256051c")
    end
  end

  describe "#generate_request" do
    it "should raise ArgumentError for argument that is not a string" do
      expect{FyberApi.generate_request(nil)}.to raise_error(ArgumentError)
    end

    it "should generate request if query is empty" do
      query_obj = FyberApi.generate_request("")
      expect(query_obj).to be_a URI
      expect(query_obj.path).to eq("/feed/v1/offers.json")
      expect(query_obj.query).to eq("&hashkey=30a44399d4d6844281d2238be8e81d309256051c")
    end

    it "should generate request from query" do
      query_obj = FyberApi.generate_request(query)
      expect(query_obj).to be_a URI
      expect(query_obj.path).to eq("/feed/v1/offers.json")
      expect(query_obj.query).to eq("appid=123&device_id=456&ip=1.1.1.1&locale=de&offer_types=112&page=1&timestamp=1428530400&uid=player1&hashkey=6935d641aee426fbf5c6fc7814747a47099ca48b")
    end
  end

  describe "connect" do
    it "connects with success and recives content" do
      stub_request(:get, "http://api.sponsorpay.com/feed/v1/offers.json?appid=123&device_id=456&ip=1.1.1.1&locale=de&offer_types=112&timestamp=1428530400&uid=player1&hashkey=df93030372a363507eb8982867fb2ea4c403b8ae").
        to_return(body: File.read(Rails.root.join('spec', 'assets', 'fyber_response.json')), status: 200, headers: { 'X-Sponsorpay-Response-Signature' => "6c9f76684e5694c8ca63a6635edf6734e8ccc098"})
      connect = FyberApi.connect(uid: 'player1')
      expect(connect.valid?).to eq(true)
      expect(connect.code).to eq(" OK")
      expect(connect.message).to eq("OK")
      expect(connect.count).to eq(1)
      expect(connect.pages).to eq(1)
      expect(connect.information).to be_a Hash
      expect(connect.offers).to be_a Array
      expect(connect.offers.size).to eq(1)
      expect(connect.offers.first['title']).to eq("Tap  Fish")
      expect(connect.offers.first['payout']).to eq(90)
      expect(connect.offers.first['thumbnail']).to be_a Hash
      expect(connect.offers.first['thumbnail']['lowres']).to eq('http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_60.png')
    end

    it "connects but there is no content for us" do
      stub_request(:get, "http://api.sponsorpay.com/feed/v1/offers.json?appid=123&device_id=456&ip=1.1.1.1&locale=de&offer_types=112&timestamp=1428530400&uid=player1&hashkey=df93030372a363507eb8982867fb2ea4c403b8ae").
        to_return(body: File.read(Rails.root.join('spec', 'assets', 'fyber_response_no_content.json')), status: 200, headers: { 'X-Sponsorpay-Response-Signature' => "a2425d199b083ea414b09c75f7be78796e9f62f0"})
      connect = FyberApi.connect(uid: 'player1')
      expect(connect.valid?).to eq(true)
      expect(connect.code).to eq("NO_CONTENT")
      expect(connect.message).to eq("Successful request, but no offers are currently available for this user.")
      expect(connect.count).to eq(0)
      expect(connect.pages).to eq(0)
      expect(connect.information).to be_a Hash
      expect(connect.offers).to be_a Array
      expect(connect.offers.size).to eq(0)
      expect{connect.offers.first['title']}.to raise_error(NoMethodError)
    end

    it "connects but is not valid" do
      stub_request(:get, "http://api.sponsorpay.com/feed/v1/offers.json?appid=123&device_id=456&ip=1.1.1.1&locale=de&offer_types=112&timestamp=1428530400&uid=player1&hashkey=df93030372a363507eb8982867fb2ea4c403b8ae").
        to_return(body: File.read(Rails.root.join('spec', 'assets', 'fyber_bad_response.json')), status: 400)
      connect = FyberApi.connect(uid: 'player1')
      expect(connect.valid?).to eq(false)
      expect(connect.code).to eq("ERROR_INVALID_APPID")
      expect(connect.message).to eq("An invalid application id (appid) was given as a parameter in the request.")
      expect(connect.offers).to eq(nil)
    end
  end

  describe "#validate" do
    context "invalid" do
      it { expect{FyberApi.send(:validate, 22)}.to raise_error(ArgumentError) }
    end

    context "valid" do
      it { expect{FyberApi.send(:validate, "abc")}.not_to raise_error() }
    end
  end

end