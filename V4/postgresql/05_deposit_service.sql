CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE deposits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id VARCHAR(50) NOT NULL UNIQUE,
  customer_id UUID NOT NULL,
  amount NUMERIC(20,4) NOT NULL CHECK (amount > 0),
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  payment_method VARCHAR(30) NOT NULL,
  payment_account_id UUID,
  payment_reference VARCHAR(255),
  proof_file_id UUID,
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  approval_state VARCHAR(40) NOT NULL DEFAULT 'PENDING_ADMIN',
  credited_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE deposit_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deposit_id UUID NOT NULL REFERENCES deposits(id),
  reviewer_id UUID NOT NULL,
  reviewer_role VARCHAR(20) NOT NULL CHECK (
    reviewer_role IN ('ADMIN','SUPER_ADMIN')
  ),
  decision VARCHAR(30) NOT NULL CHECK (
    decision IN ('APPROVED','REJECTED')
  ),
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_deposits_state ON deposits(approval_state, created_at);
CREATE INDEX idx_deposits_customer ON deposits(customer_id, created_at);
