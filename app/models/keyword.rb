class Keyword < ApplicationRecord
  belongs_to :tag, inverse_of: :keywords

  validates :tag, presence: true
end