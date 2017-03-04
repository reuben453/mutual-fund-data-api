class MutualFund < ApplicationRecord

	has_many :navs, :inverse_of => :mutual_fund

  def self.create_if_missing!(code:, name:, isin_growth: nil, isin_div_reinvestment: nil, mf_house_name: nil, scheme_category: nil)
    mf = MutualFund.find_by(code: code)

    if mf.present? && (mf.name != name || mf.isin_growth != isin_growth || mf.isin_div_reinvestment != isin_div_reinvestment || mf.mf_house_name != mf_house_name || mf.scheme_category != scheme_category)
      puts "Updating mf #{mf.code} from #{mf.as_json}"
      mf.update_attributes!({
        isin_growth: isin_growth,
        isin_div_reinvestment: isin_div_reinvestment,
        name: name,
        mf_house_name: mf_house_name,
        scheme_category: scheme_category
      })
      puts "To #{mf.reload.as_json}"
    end

    if mf.blank?
      puts "Creating new MutualFund #{code} #{name}"
      mf = MutualFund.create!({
        code: code,
        isin_growth: isin_growth,
        isin_div_reinvestment: isin_div_reinvestment,
        name: name,
        # net_asset_value: items[4].to_f,
        # repurchase_price: items[5].to_f,
        # sale_price: items[6].to_f,
        # date: Time.parse(items[7]).in_time_zone('Asia/Kolkata'),
        mf_house_name: mf_house_name,
        scheme_category: scheme_category
      })
    end

    return mf
  end

end
