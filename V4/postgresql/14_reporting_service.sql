CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE reporting_daily_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_date DATE NOT NULL,
  customer_id UUID,
  admin_id UUID,
  arena VARCHAR(30),
  volume NUMERIC(20,4) NOT NULL DEFAULT 0,
  deposits NUMERIC(20,4) NOT NULL DEFAULT 0,
  withdrawals NUMERIC(20,4) NOT NULL DEFAULT 0,
  invested NUMERIC(20,4) NOT NULL DEFAULT 0,
  pnl NUMERIC(20,4) NOT NULL DEFAULT 0,
  UNIQUE(metric_date, customer_id, admin_id, arena)
);

CREATE INDEX idx_reporting_date ON reporting_daily_metrics(metric_date);
CREATE INDEX idx_reporting_customer ON reporting_daily_metrics(customer_id, metric_date);
CREATE INDEX idx_reporting_admin ON reporting_daily_metrics(admin_id, metric_date);
