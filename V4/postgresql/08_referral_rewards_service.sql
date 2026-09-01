CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE referral_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id UUID NOT NULL,
  code VARCHAR(100) NOT NULL UNIQUE,
  valid_from TIMESTAMPTZ NOT NULL DEFAULT now(),
  valid_until TIMESTAMPTZ,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (valid_until IS NULL OR valid_until > valid_from)
);

CREATE TABLE referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referral_code_id UUID NOT NULL REFERENCES referral_codes(id),
  referrer_user_id UUID NOT NULL,
  referred_user_id UUID NOT NULL UNIQUE,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  CHECK (referrer_user_id <> referred_user_id)
);

CREATE TABLE referral_qualifying_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referral_id UUID NOT NULL REFERENCES referrals(id),
  source_type VARCHAR(50) NOT NULL,
  source_id UUID NOT NULL,
  qualifying_amount NUMERIC(20,4),
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(referral_id, source_type, source_id)
);

CREATE TABLE gold_coin_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE,
  coin_balance NUMERIC(20,4) NOT NULL DEFAULT 0 CHECK (coin_balance >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE reward_conversions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  coins NUMERIC(20,4) NOT NULL CHECK (coins > 0),
  money_amount NUMERIC(20,4) NOT NULL CHECK (money_amount > 0),
  currency CHAR(3) NOT NULL DEFAULT 'INR',
  conversion_rate NUMERIC(20,8) NOT NULL CHECK (conversion_rate > 0),
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  ledger_transaction_id UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE gold_coin_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID NOT NULL REFERENCES gold_coin_accounts(id),
  referral_id UUID REFERENCES referrals(id),
  reward_conversion_id UUID REFERENCES reward_conversions(id),
  type VARCHAR(30) NOT NULL CHECK (type IN ('EARN','ADJUST','CONVERT')),
  coins NUMERIC(20,4) NOT NULL CHECK (coins > 0),
  idempotency_key VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_referrals_referred_user ON referrals(referred_user_id);
CREATE INDEX idx_coin_transactions_account ON gold_coin_transactions(account_id, created_at);
CREATE INDEX idx_coin_transactions_conversion ON gold_coin_transactions(reward_conversion_id);
