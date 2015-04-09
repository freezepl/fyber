require 'rails_helper'

RSpec.describe OffersController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #index" do
    let(:offer_params) { {uid: "player1", pub0: nil, page: nil } }
    let(:offers) { [
      {
        "title": "Tap  Fish",
        "thumbnail": {
         "lowres": "http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_60.png",
         "hires": "http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_175.png"
        },
        "payout": 90
      }
     ]}
    let(:fyber) { instance_double("FyberApi::Response", offers: offers) }

    before do
      expect(FyberApi).to receive(:connect).with(offer_params).and_return(fyber)
      expect(fyber).to receive(:offers).and_return(offers)
    end

    it "returns http success" do
      xhr :post, :index, { 'offer': {uid: "player1" } }
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end
  end

end
