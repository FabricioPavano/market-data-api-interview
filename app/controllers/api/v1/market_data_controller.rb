class Api::V1::MarketDataController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def create
    # Extract crm_id from request body
    crm_id = params[:crm_id]
    
    if crm_id.blank?
      return render json: { error: "crm_id is required" }, status: :bad_request
    end
    
    # Find property by crm_id
    property = Property.find_by(crm_id: crm_id)
    
    if property.nil?
      return render json: { error: "Property not found" }, status: :not_found
    end
    
    # Check cache unless refresh=true
    refresh = params[:refresh] == 'true'
    cached_data = MarketData.find_by(crm_id: crm_id)
    
    # Use cache if exists and not stale (unless refresh requested)
    if cached_data && !cached_data.stale? && !refresh
      return render json: format_response(property, cached_data, cache_hit: true)
    end
    
    # Call RentCast API
    begin
      service = RentcastService.new
      api_data = service.get_property_data(property)
      
      # Cache the results
      if cached_data
        # Update existing record
        cached_data.update!(
          value_payload: api_data[:value],
          rent_payload: api_data[:rent],
          fetched_at: Time.current
        )
      else
        # Create new record
        cached_data = MarketData.create!(
          crm_id: crm_id,
          value_payload: api_data[:value],
          rent_payload: api_data[:rent],
          fetched_at: Time.current
        )
      end
      
      # Return formatted response
      render json: format_response(property, cached_data, cache_hit: false)
      
    rescue => e
      Rails.logger.error "Failed to fetch market data: #{e.message}"
      render json: { error: "Failed to fetch market data" }, status: :service_unavailable
    end
  end
  
  private
  
  def format_response(property, market_data, cache_hit:)
    value_data = market_data.value_payload
    rent_data = market_data.rent_payload
    
    {
      crm_id: property.crm_id,
      property: {
        address_line1: property.address_line1,
        city: property.city,
        state: property.state,
        zip: property.zip
      },
      avm: {
        value: {
          amount: value_data['price'],
          low: value_data['priceRangeLow'],
          high: value_data['priceRangeHigh'],
          currency: 'USD'
        },
        rent: {
          amount: rent_data['rent'],
          low: rent_data['rentRangeLow'],
          high: rent_data['rentRangeHigh'],
          period: 'month',
          currency: 'USD'
        }
      },
      fetched_at: market_data.fetched_at.iso8601,
      cache: {
        hit: cache_hit
      },
      raw: {
        value: value_data,
        rent: rent_data
      }
    }
  end
end