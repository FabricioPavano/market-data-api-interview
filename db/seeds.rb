# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Sample properties for testing the market data API
Property.find_or_create_by!(crm_id: "ABC-123") do |property|
  property.address_line1 = "123 Main St"
  property.city = "Austin"
  property.state = "TX"
  property.zip = "78701"
end

Property.find_or_create_by!(crm_id: "DEF-456") do |property|
  property.address_line1 = "456 Oak Ave"
  property.city = "Austin"
  property.state = "TX" 
  property.zip = "78702"
end
