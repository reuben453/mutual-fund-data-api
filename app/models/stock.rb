class Stock < ApplicationRecord

  has_many :share_prices, :inverse_of => :stock

  def self.create_if_missing(name:)
    stock = self.where(name: name).first

    if stock.blank?
      stock = self.create!({
        name: name
      })
    end

    return stock
  end

  def add_share_price(open: nil, close: nil, high: nil, low: nil, date:)
    self.share_prices.create!({
      open: open,
      close: close,
      high: high,
      low: low,
      date: date
    })
  end

end