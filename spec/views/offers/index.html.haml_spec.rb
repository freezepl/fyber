require 'rails_helper'

RSpec.describe "offers/index.html.haml", type: :view do
  it 'renders page with form' do
    render
    expect(rendered).to have_selector('form') do |form|
     expect(form).to have_selector('input#offer_uid', name: 'offer[uid]')
     expect(form).to have_selector('input#offer_pub0', name: 'offer[pub0]')
     expect(form).to have_selector('input#offer_page', name: 'offer[page]')
   end
  end

end
