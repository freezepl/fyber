require 'net/http'
require 'digest/sha1'

module FyberApi
  API_URL = 'http://api.sponsorpay.com/feed/v1/offers.json'
  extend self

  def connect(options={})
    query = query_string(options)
    request = generate_request(query)
    begin
      response = Net::HTTP.get_response(request)
      Response.new response
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, SocketError,
      Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError => e
      puts "Failed to connect: #{e}"
    end
  end

  def default_options
    {
      appid: app_id,
      device_id: device_id,
      locale: locale,
      ip: ip,
      offer_types: offer_types,
      timestamp: Time.now.to_i
    }
  end

  def app_id
    @app_id ||= Rails.application.secrets.fyber_app_id
  end

  def device_id
    @device_id ||= Rails.application.secrets.fyber_device_id
  end

  def locale
    @locale ||= Rails.application.secrets.fyber_locale
  end

  def ip
    @ip ||= Rails.application.secrets.fyber_ip
  end

  def offer_types
    @offer_types ||= Rails.application.secrets.fyber_offer_types
  end

  def api_key
    @api_key ||= Rails.application.secrets.fyber_api_key
  end

  def query_string(options={})
    default_options.merge(options).delete_if{ |k, v| v.nil? || v == "" }.sort.map{ |arr| "#{arr[0]}=#{arr[1]}" }.join("&")
  end

  def hashkey_calculation(query)
    validate(query)
    query += '&' + api_key.to_s
    Digest::SHA1.hexdigest(query)
  end

  def generate_request(query)
    validate(query)
    URI(API_URL + '?' + query + "&hashkey=" + hashkey_calculation(query))
  end

  private

  def validate(query)
    raise(ArgumentError, ":query must be a string") unless query.is_a?(String)
  end


  class Response
    attr_reader :response

    def initialize(response)
      @response = response
      @body = JSON.parse(response.body)
    end

    def code
      @body['code']
    end

    def message
      @body['message']
    end

    def count
      @body['count']
    end

    def pages
      @body['pages']
    end

    def information
      @body['information']
    end

    def offers
      @body['offers']
    end

    def valid?
      @response['X-Sponsorpay-Response-Signature'] == Digest::SHA1.hexdigest(@response.body + FyberApi.api_key.to_s )
    end
  end

end