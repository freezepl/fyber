class OffersController < ApplicationController
  def index
    if request.post? && offer_params.present?
      fyber = FyberApi.connect(offer_params)
      @offers = fyber.offers
    end
  end

  private

  def offer_params
    p = params['offer']
    {
      uid: p['uid'],
      pub0: p['pub0'],
      page: p['page']
    }
  end
end
