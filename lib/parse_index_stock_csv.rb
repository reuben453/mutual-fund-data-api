require File.expand_path('../../config/environment',  __FILE__)
# require 'active_record'

HEADERS = ["Date","Open","High","Low", "Close"]
ITEM_HEADERS = ['date', 'open', 'high', 'low', 'close']

filename = ARGV.first
stock_name = ARGV.second

ActiveRecord::Base.transaction do
  stock = Stock.create_if_missing(name: stock_name)

  open(filename) do |csv|
    # mf_name = csv.first.strip
    headers = csv.first.split(',').map(&:strip)
    if headers != HEADERS
      raise "Error: CSV Headers have changed from '#{HEADERS}' to '#{headers}'"
    end

    # mf = MutualFund.find_by(name: mf_name)

    csv.each do |line|
      items = line.split(',').map(&:strip)
      # items = items.collect{|i| Nav::AMFINDIA_CSV_IGNORED_VALUES.include?(i) ? nil : i}

      items = ITEM_HEADERS.zip(items).to_h.with_indifferent_access

      if items[:open].present? || items[:close].present? || items[:high].present? || items[:low].present?
        stock.add_share_price(open: items[:open], close: items[:close], high: items[:high], low: items[:low], date: items[:date])
      end

      # mf.navs.create!({
      #   net_asset_value: items[:net_asset_value],
      #   repurchase_price: items[:repurchase_price],
      #   sale_price: items[:sale_price],
      #   :date => items[:date]
      # })
    end
  end
end