class CreateProperties < ActiveRecord::Migration[7.2]
  def change
    create_table :properties do |t|
      t.string :crm_id
      t.string :address_line1
      t.string :city
      t.string :state
      t.string :zip

      t.timestamps
    end
    add_index :properties, :crm_id, unique: true
  end
end
