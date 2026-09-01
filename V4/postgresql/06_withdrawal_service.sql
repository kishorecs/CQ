CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE customer_payout_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL,
  type VARCHAR(20) NOT NULL CHECK (type IN ('BANK','UPI','CRYPTO')),
  account_data_encrypted TEXT NOT NULL,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX ux_default_payout
  ON customer_payout_accounts(customer_id)
  WHERE is_default = TRUE;

CREATE TABLE withdrawals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id VARCHAR(50) NOT NULL UNIQUE,
  customer_id UUID NOT NULL,
  payout_account_id UUID REFERENCES customer_payout_accounts(id),
  amount NUMERIC(20,4) NOT NULL CHECK (amount > 0),
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
  approval_state VARCHAR(40) NOT NULL DEFAULT 'PENDING_ADMIN',
  admin_comment TEXT,
  payout_reference VARCHAR(255),
  failure_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE withdrawal_reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  withdrawal_id UUID NOT NULL REFERENCES withdrawals(id),
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

CREATE INDEX idx_withdrawals_state ON withdrawals(approval_state, created_at);
CREATE INDEX idx_withdrawals_customer ON withdrawals(customer_id, created_at);
