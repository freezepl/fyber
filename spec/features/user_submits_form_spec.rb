require 'rails_helper'

feature 'form' do
  let(:offers) { [ {"title": "Tap  Fish", "thumbnail":
      {"lowres": "http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_60.png"},"payout": 90} ] }

  scenario 'User fill out form and submit it' do
    stub_request(:get, /api.sponsorpay.com/).
      to_return(body: File.read(Rails.root.join('spec', 'assets', 'fyber_response.json')),
      status: 200, headers: { 'X-Sponsorpay-Response-Signature' => "6c9f76684e5694c8ca63a6635edf6734e8ccc098"})
    visit root_path
    fill_in 'offer_uid', with: "player1"
    fill_in 'offer_pub0', with: "campaign2"
    fill_in 'offer_page', with: "1"
    click_on 'Request Offers'
    expect(page).to have_css('.title')
  end
end