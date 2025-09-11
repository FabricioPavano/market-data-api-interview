class MarketData < ApplicationRecord
  validates :crm_id, presence: true, uniqueness: true
  validates :fetched_at, presence: true
  
  # JSON serialization for text fields (since SQLite doesn't have native JSON)  
  serialize :value_payload, coder: JSON
  serialize :rent_payload, coder: JSON
  
  # Helper method to check if cache is stale (> 7 days)
  def stale?
    fetched_at < 7.days.ago
  end
end
