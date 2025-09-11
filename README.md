# Market Data API - Pair Programming Interview

## Objective

Build a Rails API endpoint that fetches property valuation and rental data from RentCast API.

**Time limit: 50 minutes**

## Requirements

### Endpoint

- `POST /api/v1/market_data`
- Body: `{"crm_id": "ABC-123"}`
- Optional: `?refresh=true` query parameter

**Your endpoint should be available at:**
```
POST http://localhost:3000/api/v1/market_data
```

### Flow

1. Look up property by `crm_id` (Property model already exists)
2. Call RentCast API for value and rent data
3. Store raw responses in database (simple caching)
4. Return merged JSON response
5. Cache for 7 days unless `refresh=true`

### Expected Response Format

```json
{
  "crm_id": "ABC-123",
  "property": {
    "address_line1": "123 Main St",
    "city": "Austin",
    "state": "TX",
    "zip": "78701"
  },
  "avm": {
    "value": {"amount": 450000, "low": 420000, "high": 480000, "currency": "USD"},
    "rent": {"amount": 2800, "low": 2600, "high": 3000, "period": "month", "currency": "USD"}
  },
  "fetched_at": "2023-12-01T10:30:00Z",
  "cache": {"hit": false},
  "raw": {
    "value": {...},
    "rent": {...}
  }
}
```

## RentCast API

**Base URL:** `https://api.rentcast.io/v1`

**Headers:** `X-Api-Key: YOUR_API_KEY`

**Endpoints:**

- `GET /avm/value?address=123 Main St&city=Austin&state=TX&zipCode=78701`
- `GET /avm/rent/long-term?address=123 Main St&city=Austin&state=TX&zipCode=78701`

### Example RentCast API Responses

**Value Endpoint Response:**
```json
{
  "avm": {
    "amount": 423700,
    "low": 380430,
    "high": 467070,
    "currency": "USD"
  },
  "propertyDetails": {
    "address": "1600 Barton Springs Rd, Austin, TX 78704",
    "bedrooms": 2,
    "bathrooms": 2,
    "squareFootage": 1200
  }
}
```

**Rent Endpoint Response:**
```json
{
  "rent": {
    "amount": 2150,
    "low": 1935,
    "high": 2365,
    "period": "month",
    "currency": "USD"
  },
  "propertyDetails": {
    "address": "1600 Barton Springs Rd, Austin, TX 78704",
    "bedrooms": 2,
    "bathrooms": 2,
    "squareFootage": 1200
  }
}
```

## Setup

1. **Install dependencies:**

```bash
bundle install
```

2. **Run migrations and seed data:**

```bash
rails db:migrate
rails db:seed
```

3. **Start server:**

```bash
rails server
```

4. **Set up environment variable:**

Create `.env` file in project root:
```
RENTCAST_API_KEY=25dfb8c5700b42cebdc726df295c35ab
```

5. **Test with existing property:**

**Example property address:** `1600 Barton Springs Rd, Austin, TX 78704` (CRM ID: `ABC-123`)

```bash
curl -X POST http://localhost:3000/api/v1/market_data \
  -H "Content-Type: application/json" \
  -d '{"crm_id":"ABC-123"}'
```

## What You Need to Build

1. **Migration**: Create `market_data` table

   - `crm_id` (string, unique index)
   - `value_payload` (jsonb)
   - `rent_payload` (jsonb)
   - `fetched_at` (datetime)

2. **Routes**: Add API namespace and endpoint

3. **Controller**: Handle the POST request with caching logic

4. **Service**: RentCast API client using HTTParty

5. **Model**: MarketData with validations

## Time Budget Suggestion

- 5 min: Migration + model
- 15 min: Controller with caching logic
- 10 min: RentCast client service
- 15 min: Testing + debugging
- 5 min: Stretch goals (if time permits)

## Existing Setup

- ✅ Rails app with API configuration
- ✅ Property model with sample data (`ABC-123`, `DEF-456`)
- ✅ HTTParty gem for HTTP requests
- ✅ Environment variable for `RENTCAST_API_KEY`

## Notes
