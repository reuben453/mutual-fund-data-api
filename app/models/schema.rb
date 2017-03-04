MutualFundType = GraphQL::ObjectType.define do
  name 'MutualFund'
  description 'A mutual fund'

  # field :id, !types.ID
  field :code, !types.String
  field :name, !types.String
  field :isinGrowth, types.String, property: :isin_growth
  field :isinDivReinvestment, types.String, property: :isin_div_reinvestment
  field :mfHouseName, !types.String, property: :mf_house_name
  field :schemeCategory, types.String, property: :scheme_category
  field :navs, types[NavType] # -> { types[NavType] }, 'Navs of this mutual fund'
  # field :fullName do
  #   type !types.String
  #   description 'Every name, all at once'
  #   resolve -> (obj, args, ctx) { "#{obj.first_name} #{obj.last_name}" }
  # end
end

NavType = GraphQL::ObjectType.define do
  name "Nav"

  field :netAssetValue, !types.Float, property: :net_asset_value
  field :repurchasePrice, !types.Float, property: :repurchase_price
  field :salePrice, !types.Float, property: :sale_price
  field :date, !types.String do
    resolve ->(obj, args, ctx) {
      obj.date.iso8601
    }
  end
  field :mutualFund, MutualFundType #-> { types.MutualFundType }

end

QueryType = GraphQL::ObjectType.define do
  name 'Query'
  description 'The root of all queries'

  field :allMutualFunds do
    type types[MutualFundType]
    description 'Everyone in the Universe'
    resolve -> (obj, args, ctx) { MutualFund.all }
  end
  field :mutualFund do
    type types[MutualFundType]
    description 'A Mutual fund'
    argument :code, types.String
    argument :isinDivReinvestment, types.String
    argument :isinGrowth, types.String
    resolve -> (obj, args, ctx) {
      mfs = MutualFund
      if args[:code].present?
        mfs = MutualFund.where(code: args[:code])
      end
      if args[:isinDivReinvestment].present?
        mfs = MutualFund.where(isin_div_reinvestment: args[:isinDivReinvestment])
      end
      if args[:isinGrowth].present?
        mfs = MutualFund.where(isin_growth: args[:isinGrowth])
      end
      mfs.all
    }
  end
end

Schema = GraphQL::Schema.define do
  query QueryType
end