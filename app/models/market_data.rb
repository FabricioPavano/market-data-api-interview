class MarketData < ApplicationRecord
    validates :crm_id, presence: true, uniqueness: true
    validates :fetched_at, presence: true
    
    serialize :value_payload, coder: JSON
    serialize :rent_payload, coder: JSON

    def fresh?
        fetched_at > 7.days.ago
    end
end
