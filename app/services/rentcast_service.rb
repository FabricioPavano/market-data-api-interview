require 'httparty'

class RentcastService
  include HTTParty
  
  base_uri 'https://api.rentcast.io/v1'
  
  def initialize(api_key = ENV['RENTCAST_API_KEY'])
    @api_key = api_key
  end
  
  def get_property_data(property)
    # Build query parameters from property address
    query_params = {
      address: property.address_line1,
      city: property.city,
      state: property.state,
      zipCode: property.zip
    }
    
    # Make requests to both endpoints
    value_data = get_value_data(query_params)
    rent_data = get_rent_data(query_params)
    
    {
      value: value_data,
      rent: rent_data
    }
  end
  
  private
  
  def get_value_data(query_params)
    make_request('/avm/value', query_params)
  end
  
  def get_rent_data(query_params)
    make_request('/avm/rent/long-term', query_params)
  end
  
  def make_request(path, params)
    Rails.logger.info "Calling RentCast API: #{path} with params: #{params}"
    Rails.logger.info "API Key: #{@api_key.present? ? 'Present' : 'Missing'}"
    
    options = {
      query: params,
      headers: {
        'X-Api-Key' => @api_key
      }
    }
    
    response = self.class.get(path, options)
    
    if response.success?
      response.parsed_response
    else
      Rails.logger.error "API Error: #{response.code} - #{response.body}"
      raise "RentCast API error: #{response.code} - #{response.message}"
    end
  rescue => e
    Rails.logger.error "RentCast API call failed: #{e.message}"
    raise e
  end
end