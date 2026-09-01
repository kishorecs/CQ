CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id UUID NOT NULL,
  wallet_type VARCHAR(20) NOT NULL CHECK (wallet_type IN ('GLOBAL','ARENA')),
  arena VARCHAR(20) CHECK (arena IN ('IGAMING','SPORTSBOOK','TRADING')),
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  available_balance NUMERIC(20,4) NOT NULL DEFAULT 0 CHECK (available_balance >= 0),
  locked_balance NUMERIC(20,4) NOT NULL DEFAULT 0 CHECK (locked_balance >= 0),
  version BIGINT NOT NULL DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (
    (wallet_type = 'GLOBAL' AND arena IS NULL)
    OR
    (wallet_type = 'ARENA' AND arena IS NOT NULL)
  ),
  UNIQUE(owner_user_id, wallet_type, arena, currency)
);

CREATE TABLE wallet_transfers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_wallet_id UUID NOT NULL REFERENCES wallets(id),
  destination_wallet_id UUID NOT NULL REFERENCES wallets(id),
  amount NUMERIC(20,4) NOT NULL CHECK (amount > 0),
  transfer_type VARCHAR(30) NOT NULL CHECK (
    transfer_type IN ('GLOBAL_TO_ARENA','ARENA_TO_GLOBAL')
  ),
  idempotency_key VARCHAR(255) NOT NULL UNIQUE,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','COMPLETED','FAILED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE wallet_holds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES wallets(id),
  reference_type VARCHAR(50) NOT NULL,
  reference_id UUID NOT NULL,
  amount NUMERIC(20,4) NOT NULL CHECK (amount > 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  released_at TIMESTAMPTZ
);

CREATE TABLE wallet_operations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id UUID NOT NULL REFERENCES wallets(id),
  operation_type VARCHAR(40) NOT NULL,
  amount NUMERIC(20,4) NOT NULL CHECK (amount > 0),
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  reference_type VARCHAR(50),
  reference_id UUID,
  idempotency_key VARCHAR(255) NOT NULL UNIQUE,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_wallet_owner ON wallets(owner_user_id);
CREATE INDEX idx_wallet_transfer_status ON wallet_transfers(status, created_at);
CREATE INDEX idx_wallet_holds_active ON wallet_holds(wallet_id)
  WHERE released_at IS NULL;
