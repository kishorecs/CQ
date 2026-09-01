CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE igaming_games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider VARCHAR(100) NOT NULL,
  game_code VARCHAR(150) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  category VARCHAR(50) NOT NULL,
  status VARCHAR(30) NOT NULL
);

CREATE TABLE igaming_rounds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  game_id UUID NOT NULL REFERENCES igaming_games(id),
  customer_id UUID NOT NULL,
  external_round_id VARCHAR(255),
  status VARCHAR(30) NOT NULL,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

CREATE TABLE igaming_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  round_id UUID NOT NULL REFERENCES igaming_rounds(id),
  type VARCHAR(30) NOT NULL CHECK (
    type IN ('BET','WIN','REFUND','ADJUSTMENT')
  ),
  amount NUMERIC(20,4) NOT NULL CHECK (amount > 0),
  status VARCHAR(30) NOT NULL,
  idempotency_key VARCHAR(255) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
