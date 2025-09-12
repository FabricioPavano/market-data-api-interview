class RentCastService
    include HTTParty
    base_uri 'https://api.rentcast.io/v1'

    attr_accessor :property

    def initialize(property)
        @property = property
        @params = {
            address: property.address_line1,
            city: property.city,
            state: property.state,
            zipCode: property.zip
        }
    end

    def fetch_rent_cast_apis
       value_path = "/avm/value"
       rent_path = "/avm/rent/long-term"

       value_response = fetch_api(value_path)
       rent_response = fetch_api(rent_path)
    
       [value_response, rent_response]
    end

    def fetch_api(path)
        api_key = ENV["RENTCAST_API_KEY"]
        raise 'RENTCAST_API_KEY environment variable is required' unless api_key

        options = {
            query: @params,
            headers: {
                'X-Api-Key' => ENV["RENTCAST_API_KEY"]
            }
        }
        response = self.class.get(path, options)
    end
end