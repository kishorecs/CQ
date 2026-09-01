CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE payment_providers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  configuration_encrypted TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE payment_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type VARCHAR(20) NOT NULL CHECK (type IN ('BANK','UPI','CRYPTO')),
  account_name VARCHAR(255),
  sensitive_data_encrypted TEXT NOT NULL,
  qr_file_id UUID,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
  created_by UUID NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE payment_account_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_account_id UUID NOT NULL REFERENCES payment_accounts(id),
  version_number INT NOT NULL,
  snapshot JSONB NOT NULL,
  changed_by UUID NOT NULL,
  change_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(payment_account_id, version_number)
);

CREATE TABLE payment_setting_change_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_account_id UUID NOT NULL REFERENCES payment_accounts(id),
  requested_by UUID NOT NULL,
  requested_snapshot JSONB NOT NULL,
  reason TEXT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','APPROVED','REJECTED')),
  approved_by UUID,
  approved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE payment_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID REFERENCES payment_providers(id),
  reference_type VARCHAR(50) NOT NULL,
  reference_id UUID NOT NULL,
  amount NUMERIC(20,4),
  external_reference VARCHAR(255),
  status VARCHAR(30) NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
