class CreateMarketData < ActiveRecord::Migration[7.2]
  def change
    create_table :market_data do |t|
      t.string :crm_id
      t.text :value_payload
      t.text :rent_payload
      t.datetime :fetched_at

      t.timestamps
    end
    
    add_index :market_data, :crm_id, unique: true
  end
end
