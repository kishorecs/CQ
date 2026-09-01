CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Database-per-service deployment:
-- Run each numbered service migration only in its owning service database.
-- Cross-service UUID references intentionally do NOT use PostgreSQL foreign keys.
