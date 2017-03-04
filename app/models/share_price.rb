class SharePrice < ApplicationRecord

  belongs_to :stock, :inverse_of => :share_prices

end