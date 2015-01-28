require 'sinatra'
require 'net/http'
require_relative 'config'
require "json"

get '/:currency/?' do
  currency = params[:currency].strip.upcase
  render_currency(currency, BASE_CURRENCY)
end




get '/:currency/:base_currency/?' do
  currency = params[:currency].strip.upcase
  base_currency = params[:base_currency].strip.upcase
  render_currency(currency, base_currency)
end

get '/' do
  redirect '/USD'
end

def render_currency(currency, base_currency)
  rates_json = get_rates_json
  @currency = currency
  @base_currency = base_currency

  if rates_json.has_key?(@currency) & rates_json.has_key?(@base_currency)
    @rate = get_currency_rate(rates_json, @currency, @base_currency)
    erb :main
  else
    four_o_four
  end
end

def get_rates_json
  @@global_hash ||= set_rates
  time_difference = Time.now - @@global_hash[:current_time]
  @@global_hash = set_rates if time_difference > UPDATE_RATE_SECONDS

  @@global_hash[:rates_json]
end

def set_rates
  {current_time: Time.now, rates_json: JSON.parse(get_currency)['rates']}
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

def get_base_currency_rate(rates_json, base_currency)
  rates_json[base_currency]
end

def get_currency_rate(rates_json, currency, base_currency = BASE_CURRENCY)
  base_rate = get_base_currency_rate(rates_json, base_currency)
  currency_rate = rates_json[currency]

  result = base_rate / currency_rate
  result.round(CURRENCY_DECIMAL_POINTS)
end
