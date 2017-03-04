class Tag < ApplicationRecord
  has_many :keywords, inverse_of: :tag, dependent: :destroy
  accepts_nested_attributes_for :keywords

  validates :keywords, presence: true
end