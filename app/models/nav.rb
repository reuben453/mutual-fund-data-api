class Nav < ApplicationRecord

  class DifferentNavValues < StandardError
  end

	belongs_to :mutual_fund, :inverse_of => :navs


  AMFINDIA_CSV_IGNORED_VALUES = ['#N/A', '-']


  def self.create_if_missing!(mutual_fund:, date:, net_asset_value:, repurchase_price:, sale_price:)
    nav = Nav.where(mutual_fund_id: mutual_fund.id, date: date.to_date).first

    if nav.blank?
      # begin
      nav = mutual_fund.navs.create!({
        net_asset_value: net_asset_value,
        repurchase_price: repurchase_price,
        sale_price: sale_price,
        date: date
      })
    # rescue => e
    #   binding.pry
    # end
    elsif (nav.present? && (nav.net_asset_value != net_asset_value || nav.repurchase_price != repurchase_price || nav.sale_price != sale_price))
      raise DifferentNavValues, "Error: Different nav values for the same date, mf_code: #{nav.mutual_fund.code}, date: #{nav.date}\n#{nav.net_asset_value} #{nav.repurchase_price} #{nav.sale_price}\n#{net_asset_value} #{repurchase_price} #{sale_price}"
    else
      puts "Nav already exists: #{nav.mutual_fund.code}, date: #{nav.date}, #{nav.net_asset_value}, #{nav.repurchase_price}, #{nav.sale_price}"
    end

    return nav
  end

end