CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE user_status AS ENUM ('ACTIVE','SUSPENDED','BLOCKED');

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id VARCHAR(32) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  phone VARCHAR(30),
  password_hash TEXT NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('SUPER_ADMIN','ADMIN','CUSTOMER')),
  status user_status NOT NULL DEFAULT 'ACTIVE',
  identity_fingerprint VARCHAR(128),
  last_login_at TIMESTAMPTZ,
  blocked_at TIMESTAMPTZ,
  suspended_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX ux_identity_fingerprint
  ON users(identity_fingerprint)
  WHERE identity_fingerprint IS NOT NULL;

CREATE TABLE user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  refresh_token_hash TEXT NOT NULL,
  ip_address INET,
  user_agent TEXT,
  expires_at TIMESTAMPTZ NOT NULL,
  revoked_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_mfa (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  enabled BOOLEAN NOT NULL DEFAULT FALSE,
  method VARCHAR(30) NOT NULL DEFAULT 'TOTP',
  secret_encrypted TEXT,
  backup_codes_encrypted TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
