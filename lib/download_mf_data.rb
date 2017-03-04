# require 'httparty'
require 'net/http'
require 'pry'
require 'active_support/all'

require File.expand_path('../../config/environment',  __FILE__)
require 'mutual_fund'

# response = HTTParty.get("http://portal.amfiindia.com/spages/NAV0.txt")

CSV_HEADERS = ['Scheme Code', 'ISIN Div Payout/ ISIN Growth', 'ISIN Div Reinvestment', 'Scheme Name', 'Net Asset Value', 'Repurchase Price', 'Sale Price', 'Date']
CSV_HEADER_ITEMS = ['scheme_code', 'isin_growth', 'isin_div_reinvestment', 'scheme_name', 'net_asset_value', 'repurchase_price', 'sale_price', 'date']

uri = URI('http://portal.amfiindia.com/spages/NAV0.txt')

Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Get.new(uri.request_uri)

  http.request request do |response|
    open 'temp_mf_list.csv', 'w' do |io|
      response.read_body do |chunk|
        io.write chunk
      end
    end
  end
end

open("temp_mf_list.csv") do |csv|
  headers = csv.first
  if headers.strip.split(';') != CSV_HEADERS
    raise "Error: CSV Headers have changed to #{headers}"
  end
  # is_first_line = true  # first line WIH ONE ITEM
  temp_var = nil
  mf_category = mf_house = nil

  csv.each_line do |line|
    line = line.strip
    next if line.blank?

    items = line.split(';')
    if items.length == 1
      if temp_var.blank?
        temp_var = items.first
      else
        mf_category = temp_var
        mf_house = items.first
        temp_var = nil
      end
      next
    end

    if temp_var.present?
      mf_house = temp_var
      temp_var = nil
    end

    items = items.collect{|i| Nav::AMFINDIA_CSV_IGNORED_VALUES.include?(i) ? nil : i }

    items = CSV_HEADER_ITEMS.zip(items).to_h.with_indifferent_access

    # mf = MutualFund.find_by(code: items[:scheme_code])

    mf = MutualFund.create_if_missing!(code: items[:scheme_code], name: items[:scheme_name], isin_growth: items[:isin_growth], isin_div_reinvestment: items[:isin_div_reinvestment], mf_house_name: mf_house, scheme_category: mf_category)

    date = Time.parse(items[:date]).in_time_zone('Asia/Kolkata')

    net_asset_value = BigDecimal.new(items[:net_asset_value].to_s)
    repurchase_price = BigDecimal.new(items[:repurchase_price].to_s)
    sale_price = BigDecimal.new(items[:sale_price].to_s)

    begin
      Nav.create_if_missing!(mutual_fund: mf, date: date, net_asset_value: net_asset_value, sale_price: sale_price, repurchase_price: repurchase_price)
    rescue Nav::DifferentNavValues => e
      puts "Different Nav Values: #{e}"
    end


    # process the values
  end
end


# byebug