CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE trading_instruments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol VARCHAR(100) NOT NULL UNIQUE,
  asset_class VARCHAR(50) NOT NULL,
  exchange VARCHAR(100),
  status VARCHAR(30) NOT NULL
);

CREATE TABLE market_quotes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  instrument_id UUID NOT NULL REFERENCES trading_instruments(id),
  bid NUMERIC(30,10),
  ask NUMERIC(30,10),
  last_price NUMERIC(30,10),
  quoted_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX idx_market_quotes_instrument_time
ON market_quotes(instrument_id, quoted_at DESC);

CREATE TABLE trading_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  instrument_id UUID NOT NULL REFERENCES trading_instruments(id),
  side VARCHAR(10) NOT NULL CHECK (side IN ('BUY','SELL')),
  order_type VARCHAR(20) NOT NULL,
  quantity NUMERIC(30,10) NOT NULL CHECK (quantity > 0),
  limit_price NUMERIC(30,10),
  status VARCHAR(30) NOT NULL,
  idempotency_key VARCHAR(255) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE trading_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES trading_orders(id),
  quantity NUMERIC(30,10) NOT NULL,
  price NUMERIC(30,10) NOT NULL,
  executed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE trading_positions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  instrument_id UUID NOT NULL REFERENCES trading_instruments(id),
  quantity NUMERIC(30,10) NOT NULL DEFAULT 0,
  average_price NUMERIC(30,10),
  realized_pnl NUMERIC(20,4) NOT NULL DEFAULT 0,
  unrealized_pnl NUMERIC(20,4) NOT NULL DEFAULT 0,
  UNIQUE(customer_id, instrument_id)
);
