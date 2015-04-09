require 'rails_helper'

RSpec.describe "offers/index.html.haml", type: :view do
  it 'renders page with form' do
    render
    expect(rendered).to have_selector('form') do |form|
      expect(form).to have_selector('input#offer_uid', name: 'offer[uid]')
      expect(form).to have_selector('input#offer_pub0', name: 'offer[pub0]')
      expect(form).to have_selector('input#offer_page', name: 'offer[page]')
    end
    expect(rendered).not_to have_content('No offers')
  end

  it 'renders offers' do
    assign(:offers, [ {"title": "Tap  Fish", "thumbnail":
      {"lowres": "http://cdn.sponsorpay.com/assets/1808/icon175x175-2_square_60.png"},"payout": 90} ])
    render
    expect(view).to render_template(:partial => "_offer", :count => 1)
    expect(rendered).to have_selector('.title')
    expect(rendered).to have_selector('.payout')
    expect(rendered).to have_selector('.thumbnail')
  end

  it "renders 'No offers' " do
    assign(:offers, [])
    render
    expect(rendered).to have_selector('.no_offers')
    expect(rendered).to have_content('No offers')
  end

end
