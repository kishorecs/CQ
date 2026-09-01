# AllInOne Final Backend Package

This package consolidates the earlier Super Admin design and AllInOne Platform Design Document v2.0.

## Files
- `ALLINONE_Final_Backend_Architecture_and_DB_Design.docx` — final engineering design document.
- `ALLINONE_V2_COMPLETE_ERD.mmd` — complete Mermaid ER diagram.
- `ALLINONE_END_TO_END_ARCHITECTURE.png` — service/event architecture overview.
- `ALLINONE_ERD_DOMAIN_OVERVIEW.png` — readable domain-level ERD overview.
- `postgresql/` — service-specific PostgreSQL migrations.

## Database rule
Use database-per-service ownership. Initially, databases may share a PostgreSQL cluster, but service credentials and schema ownership must remain isolated. Do not create cross-service foreign keys.

## Suggested service DBs
identity_db, user_db, wallet_db, ledger_db, deposit_db, withdrawal_db, payment_db,
referral_db, igaming_db, sportsbook_db, trading_db, risk_db, reporting_db, audit_db,
notification_db, reconciliation_db.

## Important
The source document does not specify exact reward rates, KYC fields, payment providers,
odds/trading providers, or retention periods. Configure those separately.
