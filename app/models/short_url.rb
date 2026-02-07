class ShortUrl < ApplicationRecord
  validates :target_url, presence: true
  validates :code, presence: true, uniqueness: true, length: { maximum: 15 }
end
