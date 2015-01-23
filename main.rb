require 'sinatra'
require 'net/http'
require_relative 'config'
require "json"

get '/:currency' do
  currency_json = JSON.parse(get_currency)
  rates_json = currency_json['rates']

  @currency = params[:currency]
  if rates_json.has_key?(@currency)
    @base_currency = BASE_CURRENCY
    @rate = get_currency_rate(rates_json, @currency)
    erb :main
  else
    four_o_four
  end
end

get '/' do
  redirect '/USD'
end

def four_o_four
  erb :four_o_four
end

def get_currency

  parsed_url = URI.parse('http://openexchangerates.org/api/latest.json?app_id=' + API_KEY)
  http = Net::HTTP.new(parsed_url.host, parsed_url.port)
  http.use_ssl = false
  request = Net::HTTP::Get.new(parsed_url.request_uri)

  response = http.request(request)
  response.body
end

def get_base_currency_rate(rates_json)
  rates_json[BASE_CURRENCY]
end

def get_currency_rate(rates_json, currency)
  base_rate = get_base_currency_rate(rates_json)
  currency_rate = rates_json[currency]

  result = base_rate / currency_rate
  result.round(CURRENCY_DECIMAL_POINTS)
end
