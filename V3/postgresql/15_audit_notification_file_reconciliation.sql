CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE audit_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(100) NOT NULL,
  entity_id UUID,
  before_data JSONB,
  after_data JSONB,
  ip_address INET,
  request_id VARCHAR(100),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_audit_entity 
  ON audit_events(entity_type, entity_id, created_at);

CREATE INDEX idx_audit_actor 
  ON audit_events(actor_id, created_at);

CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  type VARCHAR(100) NOT NULL,
  channel VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  metadata JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  sent_at TIMESTAMPTZ,
  read_at TIMESTAMPTZ
);

CREATE TABLE files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  storage_provider VARCHAR(30) NOT NULL,
  bucket VARCHAR(255) NOT NULL,
  object_key TEXT NOT NULL UNIQUE,
  original_filename TEXT,
  mime_type VARCHAR(100),
  size_bytes BIGINT,
  checksum_sha256 VARCHAR(64),
  status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
  uploaded_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE reconciliation_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id UUID,
  status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
  total_records INT NOT NULL DEFAULT 0,
  matched_records INT NOT NULL DEFAULT 0,
  exception_records INT NOT NULL DEFAULT 0,
  started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE reconciliation_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id UUID NOT NULL REFERENCES reconciliation_runs(id),
  reference_type VARCHAR(50) NOT NULL,
  reference_id UUID,
  external_reference VARCHAR(255),
  internal_amount NUMERIC(20,4),
  external_amount NUMERIC(20,4),
  difference NUMERIC(20,4),
  status VARCHAR(30) NOT NULL,
  resolution_note TEXT,
  resolved_by UUID,
  resolved_at TIMESTAMPTZ
);
