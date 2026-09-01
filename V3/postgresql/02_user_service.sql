CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE admin_customer_assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL,
  customer_id UUID NOT NULL,
  assigned_by UUID NOT NULL,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  unassigned_at TIMESTAMPTZ,
  CHECK (admin_id <> customer_id)
);

CREATE UNIQUE INDEX ux_one_active_admin_per_customer
  ON admin_customer_assignments(customer_id)
  WHERE unassigned_at IS NULL;

CREATE TABLE access_action_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_user_id UUID NOT NULL,
  requested_by UUID NOT NULL,
  action VARCHAR(20) NOT NULL CHECK (action IN ('SUSPEND','BLOCK')),
  reason TEXT NOT NULL CHECK (length(trim(reason)) > 0),
  status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
    CHECK (status IN ('PENDING','APPROVED','DECLINED')),
  decided_by UUID,
  decision_note TEXT,
  decided_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE user_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  old_status VARCHAR(20),
  new_status VARCHAR(20) NOT NULL,
  changed_by UUID NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
