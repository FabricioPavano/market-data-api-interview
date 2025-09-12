class Api::V1::MarketDataController < ApplicationController

    before_action :set_property

    def create
        #fetch records from api
        service = RentCastService.new(@property)
        value_response, rent_response = service.fetch_rent_cast_apis

        market_data = MarketData.new(crm_id: @property.crm_id)
        market_data.value_payload = value_response || {}
        market_data.rent_payload = rent_response || {}
        market_data.fetched_at = Time.current
            
        if market_data.save
            build_response = build_response(market_data)
            render json: build_response, status: 200
        else
            render json: { error: "Error in saving Market Data" }, status: :bad_request
        end
    end

    private

    def set_property
        crm_id = params[:crm_id]
        return render json: { error: 'crm_id is required' }, status: :bad_request unless crm_id

        @property = Property.find_by(crm_id: crm_id)
        return render json: { error: 'Property not found' }, status: :not_found unless @property
    end

    def build_response(market_data)
        {
            crm_id: market_data.crm_id,
            property: {
                address_line1: @property.address_line1,
                city: @property.city,
                state: @property.state,
                zip: @property.zip
            },
            avm: {
               value: market_data.value_payload,
               rent: market_data.rent_payload  
            },
            fetched_at: market_data.fetched_at.iso8601,
            cache: { hit: true },
            raw: {
                value: market_data.value_payload,
                rent: market_data.rent_payload
            }
        }
    end
end
