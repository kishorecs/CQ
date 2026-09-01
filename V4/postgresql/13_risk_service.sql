CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE risk_cases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID,
  reference_type VARCHAR(50) NOT NULL,
  reference_id UUID,
  score NUMERIC(10,4),
  decision VARCHAR(20) NOT NULL CHECK (decision IN ('ALLOW','REVIEW','BLOCK')),
  status VARCHAR(20) NOT NULL DEFAULT 'OPEN',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE risk_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  case_id UUID NOT NULL REFERENCES risk_cases(id),
  rule_code VARCHAR(100) NOT NULL,
  score NUMERIC(10,4),
  evidence JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
