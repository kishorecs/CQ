CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE ledger_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_code VARCHAR(100) NOT NULL UNIQUE,
  account_name VARCHAR(255) NOT NULL,
  account_type VARCHAR(20) NOT NULL CHECK (
    account_type IN ('ASSET','LIABILITY','REVENUE','EXPENSE','EQUITY')
  ),
  owner_user_id UUID,
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ledger_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reference_type VARCHAR(50) NOT NULL,
  reference_id UUID,
  business_event VARCHAR(100) NOT NULL,
  idempotency_key VARCHAR(255) NOT NULL UNIQUE,
  metadata JSONB NOT NULL DEFAULT '{}',
  posted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID NOT NULL REFERENCES ledger_transactions(id),
  ledger_account_id UUID NOT NULL REFERENCES ledger_accounts(id),
  direction VARCHAR(10) NOT NULL CHECK (direction IN ('DEBIT','CREDIT')),
  amount NUMERIC(20,4) NOT NULL CHECK (amount > 0),
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_ledger_entries_tx ON ledger_entries(transaction_id);
CREATE INDEX idx_ledger_entries_account ON ledger_entries(ledger_account_id, created_at);
