CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
);

CREATE TABLE product_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id),
  customer_id UUID NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  amount NUMERIC(20,4),
  currency CHAR(3) DEFAULT 'INR',
  metadata JSONB NOT NULL DEFAULT '{}',
  occurred_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO products(code,name) VALUES
('IGAMING','iGaming'),
('SPORTSBOOK','Sportsbook'),
('TRADING','Trading')
ON CONFLICT (code) DO NOTHING;
