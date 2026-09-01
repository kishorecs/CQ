CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE sports_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sport VARCHAR(50) NOT NULL,
  competition VARCHAR(100),
  home_team VARCHAR(255),
  away_team VARCHAR(255),
  starts_at TIMESTAMPTZ,
  status VARCHAR(30) NOT NULL
);

CREATE TABLE sports_markets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES sports_events(id),
  market_type VARCHAR(100) NOT NULL,
  odds JSONB NOT NULL DEFAULT '{}',
  status VARCHAR(30) NOT NULL
);

CREATE TABLE sports_bets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  market_id UUID NOT NULL REFERENCES sports_markets(id),
  stake NUMERIC(20,4) NOT NULL CHECK (stake > 0),
  status VARCHAR(30) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE sports_positions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  bet_id UUID NOT NULL REFERENCES sports_bets(id),
  quantity NUMERIC(20,8) NOT NULL,
  average_price NUMERIC(20,8) NOT NULL,
  realized_pnl NUMERIC(20,4) NOT NULL DEFAULT 0,
  unrealized_pnl NUMERIC(20,4) NOT NULL DEFAULT 0
);

CREATE TABLE sports_position_trades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  position_id UUID NOT NULL REFERENCES sports_positions(id),
  side VARCHAR(10) NOT NULL CHECK (side IN ('BUY','SELL')),
  quantity NUMERIC(20,8) NOT NULL CHECK (quantity > 0),
  price NUMERIC(20,8) NOT NULL,
  executed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
